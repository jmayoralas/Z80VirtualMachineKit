//
//  Tape.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 26/8/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

private enum TapeStatus {
    case sendingHeader
    case sendingData
    case sendingLeadingTone
    case sendingSyncPulse
    case sendingDataBlock
    case sendingBit
    case endBit
    case endByte
    case endDataBlock
    case pause
}

private enum TapeLevel: Int {
    case off = 0
    case on = 1
}

private let kTStatesPerSecond = 3500000

private let kPauseTStates: Int = kTStatesPerSecond

private let kLeadingToneTStatesEdgeDuration = 2168
private let kLeadingToneHeaderTStatesDuration = kTStatesPerSecond * 3
private let kLeadingToneDataTStatesDuration = kTStatesPerSecond * 2

private let kSyncPulseOffTStates = 667
private let kSyncPulseOnTStates = 735

private let kResetBitTStates = 855
private let kSetBitTStates = kResetBitTStates * 2

final class Tape {
    let ula: Ula
    let loader: TapeLoader
    
    var tapeAvailable: Bool = false
    var isPlaying: Bool = false
    private var status = TapeStatus.sendingHeader
    
    private var lastLevel = TapeLevel.off
    
    private var tCycle: Int = 0
    private var tCyclesTone: Int = 0

    private var bufferToSend: [UInt8]!
    private var indexByteToSend: Int = 0
    private var indexBitToSend: Int = 0
    
    private var leadingToneDurationTStates: Int = 0
    
    init(ula: Ula) {
        self.ula = ula
        self.loader = TapeLoader()
    }
    
    func open(path: String) throws {
        if self.tapeAvailable {
            loader.close()
            self.tapeAvailable = false
        }
        
        try loader.open(path: path)
        self.tapeAvailable = true
    }
    
    func close() {
        self.loader.close()
        self.tapeAvailable = false
    }
    
    func blockRequested() throws -> [UInt8]? {
        var tapeBlock: TapeBlock?
        
        tapeBlock = try loader.readBlock()
        
        var data: [UInt8]? = nil
        
        if let block = tapeBlock {
            data = block.data
        }
        
        return data
    }
    
    func start() throws {
        guard self.tapeAvailable else {
            throw TapeLoaderErrors.NoTapeOpened
        }
        
        if self.isPlaying {
            self.stop()
        }
        
        self.isPlaying = true
        self.status = .sendingHeader
        self.tCycle = 0
        self.tCyclesTone = 0
    }
    
    func stop() {
        self.isPlaying = false
    }
    
    func step(tCycle: Int) {
        guard self.isPlaying else {
            return
        }
        
        self.tCycle += tCycle
        self.tCyclesTone += tCycle
        
        switch self.status {
        case .pause:
            self.pause()
            
        case .sendingHeader:
            self.leadingToneDurationTStates = kLeadingToneHeaderTStatesDuration
            sendLeadingTone()
            
        case .sendingData:
            self.leadingToneDurationTStates = kLeadingToneDataTStatesDuration
            sendLeadingTone()
            
        case .sendingLeadingTone:
            sendLeadingTone()
            
        case .sendingSyncPulse:
            sendSyncPulse()
            
        case .sendingDataBlock:
            self.sendDataBlock()
        
        case .sendingBit:
            self.sendBit()
        
        case .endBit:
            self.endBit()
            
        case .endByte:
            self.endByte()
            
        case .endDataBlock:
            self.endDataBlock()
        }
    }
    
    private func pause() {
        if self.tCycle >= kPauseTStates {
            self.leadingToneDurationTStates = kLeadingToneDataTStatesDuration
            self.status = .sendingData
            self.tCycle = 0
            self.tCyclesTone = 0
        }
    }
    
    private func sendLeadingTone() {
        // this is invoked only with values .idle or .sendingLeadingTone in status
        // no need for checking any other statuses
        if self.status == .sendingHeader || self.status == .sendingData {
            self.status = .sendingLeadingTone
            self.lastLevel = .on
            self.ula.setTapeLevel(value: self.lastLevel.rawValue)
        } else {
            if self.tCyclesTone >= self.leadingToneDurationTStates {
                self.lastLevel = .off
                self.ula.setTapeLevel(value: self.lastLevel.rawValue)
                
                self.status = .sendingSyncPulse
                self.tCycle = 0
                self.tCyclesTone = 0
            } else {
                if self.tCycle >= kLeadingToneTStatesEdgeDuration {
                    self.lastLevel = (self.lastLevel == .off) ? .on : .off
                    self.ula.setTapeLevel(value: self.lastLevel.rawValue)
                    self.tCycle -= kLeadingToneTStatesEdgeDuration
                }
            }
        }
    }
    
    private func sendSyncPulse() {
        self.sendPulse(offTStates: kSyncPulseOffTStates, onTStates: kSyncPulseOnTStates, statusAfterPulse: .sendingDataBlock)
    }

    private func sendDataBlock() {
        if let tapeBlock = try! loader.readBlock() {
            self.bufferToSend = tapeBlock.data
            self.indexByteToSend = 0
            self.indexBitToSend = 7
            self.status = .sendingBit
        } else {
            self.stop()
        }
    }

    private func endDataBlock() {
        self.status = .pause
    }
    
    private func endByte() {
        self.indexByteToSend += 1
        self.indexBitToSend = 7
        self.status = (self.indexByteToSend > (self.bufferToSend.count - 1)) ? .endDataBlock : .sendingBit
    }

    private func sendBit() {
        let bitToSend = self.bufferToSend[self.indexByteToSend].bit(self.indexBitToSend)
        if bitToSend == 0 {
            self.sendPulse(offTStates: kResetBitTStates, onTStates: kResetBitTStates, statusAfterPulse: .endBit)
        } else {
            self.sendPulse(offTStates: kSetBitTStates, onTStates: kSetBitTStates, statusAfterPulse: .endBit)
        }
    }
    
    private func endBit() {
        self.indexBitToSend -= 1
        self.status = self.indexBitToSend < 0 ? .endByte : .sendingBit
    }
    
    private func sendPulse(offTStates: Int, onTStates: Int, statusAfterPulse: TapeStatus) {
        switch self.lastLevel {
        case .off:
            if self.tCycle >= offTStates {
                self.lastLevel = .on
                self.ula.setTapeLevel(value: self.lastLevel.rawValue)
                self.tCycle -= offTStates
            }
        case .on:
            if self.tCycle >= onTStates {
                self.lastLevel = .off
                self.ula.setTapeLevel(value: self.lastLevel.rawValue)
                self.tCycle -= onTStates
                self.tCyclesTone -= onTStates
                self.status = statusAfterPulse
            }
        }
        
    }
}
