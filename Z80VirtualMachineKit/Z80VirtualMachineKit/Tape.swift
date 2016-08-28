//
//  Tape.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 26/8/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

private enum TapeStatus {
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
private let kLeadingToneDataTStatesDuration = Int(Double(kTStatesPerSecond) * 3)

private let kSyncPulseOffTStates = 667
private let kSyncPulseOnTStates = 735

private let kResetBitTStates = 855
private let kSetBitTStates = kResetBitTStates * 2

final class Tape {
    let ula: Ula
    let loader: TapeLoader
    
    var tapeAvailable: Bool = false
    var isPlaying: Bool = false
    private var status = TapeStatus.sendingData
    
    private var lastLevel = TapeLevel.off
    
    private var tCycle: Int = 0
    private var tCyclesTone: Int = 0

    private var tapeBlockToSend: TapeBlock!
    private var indexByteToSend: Int = 0
    private var indexBitToSend: Int = 0
    private var blocksSendedCount: Int = 0
    
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
        self.blocksSendedCount = 0
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
            throw TapeLoaderError.NoTapeOpened
        }
        
        guard self.blocksSendedCount < self.loader.blockCount() else {
            throw TapeLoaderError.EndOfTape
        }
        if self.isPlaying {
            self.stop()
        }
        
        self.isPlaying = true
        self.status = .sendingData
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
            
        case .sendingData:
            self.sendData()
            
        case .sendingLeadingTone:
            self.sendLeadingTone()
            
        case .sendingSyncPulse:
            self.sendSyncPulse()
            
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
            self.status = .sendingData
            self.tCycle = 0
            self.tCyclesTone = 0
        }
    }
    
    private func sendData() {
        if self.blocksSendedCount < self.loader.blockCount() {
            self.blocksSendedCount += 1
            self.leadingToneDurationTStates = kLeadingToneDataTStatesDuration
            self.sendLeadingTone()
        } else {
            self.stop()
        }
        
    }
    
    private func sendLeadingTone() {
        // this is invoked only with values .idle or .sendingLeadingTone in status
        // no need for checking any other statuses
        if self.status == .sendingData {
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
        self.tapeBlockToSend = try! loader.readBlock()
        self.indexByteToSend = 0
        self.indexBitToSend = 7
        self.status = .sendingBit
    }

    private func endDataBlock() {
        self.status = .pause
    }
    
    private func endByte() {
        self.indexByteToSend += 1
        self.indexBitToSend = 7
        self.status = (self.indexByteToSend > (self.tapeBlockToSend.data.count - 1)) ? .endDataBlock : .sendingBit
    }

    private func sendBit() {
        let bitToSend = self.tapeBlockToSend.data[self.indexByteToSend].bit(self.indexBitToSend)
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
