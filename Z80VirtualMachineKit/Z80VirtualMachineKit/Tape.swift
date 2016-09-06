//
//  Tape.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 26/8/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

private enum TapeStatus {
    case sendingPulses
    case sendingData
    case pause
}

private enum TapeLevel: Int {
    case off = 0
    case on = 1
}

private struct Pulse {
    var tapeLevel: TapeLevel?
    var tStates: Int
}

private let kTStatesPerMiliSecond = 3500

private typealias AfterPulsesCallback = () -> Void

private let kEndPulseSequence = Pulse(tapeLevel: nil, tStates: 0)

final class Tape {
    
    var tapeAvailable: Bool = false
    var isPlaying: Bool = false
    
    private let ula: Ula
    private let loader: TapeLoader
    
    private var status = TapeStatus.sendingData
    
    private var lastLevel = TapeLevel.off
    
    private var tCycle: Int = 0

    private var tapeBlockToSend: TapeBlock!
    private var indexByteToSend: Int = 0
    private var indexBitToSend: Int = 0
    private var blocksSentCount: Int = 0
    
    private var leadingToneDurationTStates: Int = 0
    private var pulsesCount: Int = 0
    private var tStatesWait: Int = 0
    private var pulses: [Pulse]?
    private var indexPulse: Int = 0
    private var afterPulsesCallback: AfterPulsesCallback?
    
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
        self.blocksSentCount = 0
    }
    
    func getBlockDirectory() throws -> [TapeBlock] {
        return try self.loader.getBlockDirectory()
    }
    
    func close() {
        self.loader.close()
        self.tapeAvailable = false
    }
    
    func rewind() {
        self.loader.rewind()
    }
    
    func setCurrentBlock(index: Int) throws {
        try self.loader.setCurrentBlock(index: index)
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
        
        guard self.blocksSentCount < self.loader.blockCount() else {
            throw TapeLoaderError.EndOfTape
        }
        if self.isPlaying {
            self.stop()
        }
        
        self.isPlaying = true
        self.status = .sendingData
        self.tCycle = 0
    }
    
    func stop() {
        self.isPlaying = false
    }
    
    func step(tCycle: Int) {
        guard self.isPlaying else {
            return
        }
        
        self.tCycle += tCycle
        
        switch self.status {
        case .sendingPulses:
            self.sendPulses()
            
        case .pause:
            self.pause()
            
        case .sendingData:
            self.sendData()
        }
    }
    
    private func pause() {
        guard self.tapeBlockToSend.timingInfo.pauseAfterBlock > 0 else {
            self.stop()
            return
        }
        
        if self.tCycle >= self.tapeBlockToSend.timingInfo.pauseAfterBlock * kTStatesPerMiliSecond {
            self.status = .sendingData
            self.tCycle = 0
        }
    }
    
    private func sendData() {
        if self.blocksSentCount < self.loader.blockCount() {
            self.blocksSentCount += 1
            
            self.tapeBlockToSend = try! loader.readBlock()
            
            if self.tapeBlockToSend.identifier == kPauseTapeBlockIdentifier {
                self.status = .pause
            } else {
                self.sendLeadingTone()
            }
            
        } else {
            self.stop()
        }
        
    }
    
    private func sendLeadingTone() {
        self.pulses = []
        
        for _ in 1 ... self.tapeBlockToSend.timingInfo.pilotTonePulsesCount {
            self.pulses!.append(Pulse(tapeLevel: nil, tStates: self.tapeBlockToSend.timingInfo.pilotPulseLength))
        }
        self.pulses!.append(kEndPulseSequence)
        
        self.indexPulse = 0
        self.tCycle = 0
        
        self.status = .sendingPulses
        self.afterPulsesCallback = self.sendSyncPulse
    }
    
    private func sendSyncPulse() {
        self.pulses = [
            Pulse(tapeLevel: .off, tStates: self.tapeBlockToSend.timingInfo.syncFirstPulseLength),
            Pulse(tapeLevel: .on, tStates: self.tapeBlockToSend.timingInfo.syncSecondPulseLength),
            kEndPulseSequence
        ]
        
        self.indexPulse = 0
        self.tCycle = 0
        
        self.status = .sendingPulses
        self.afterPulsesCallback = self.sendDataBlock
    }

    private func sendDataBlock() {
        self.indexByteToSend = 0
        self.indexBitToSend = 7
        self.sendBit()
    }

    private func endDataBlock() {
        self.status = .pause
    }
    
    private func endByte() {
        self.indexByteToSend += 1
        self.indexBitToSend = 7
        
        if self.indexByteToSend >= self.tapeBlockToSend.data.count {
            self.endDataBlock()
        } else {
            self.sendBit()
        }
    }

    private func sendBit() {
        let bitTStates: Int
        
        let bitToSend = self.tapeBlockToSend.data[self.indexByteToSend].bit(self.indexBitToSend)
        
        if bitToSend == 0 {
            bitTStates = self.tapeBlockToSend.timingInfo.resetBitPulseLength
        } else {
            bitTStates = self.tapeBlockToSend.timingInfo.setBitPulseLength
        }
        
        self.pulses = [
            Pulse(tapeLevel: .off, tStates: bitTStates),
            Pulse(tapeLevel: .on, tStates: bitTStates),
            kEndPulseSequence
        ]
        
        self.indexPulse = 0
        self.tCycle = 0
        
        self.status = .sendingPulses
        self.afterPulsesCallback = self.endBit
    }
    
    private func endBit() {
        self.indexBitToSend -= 1
        if self.indexBitToSend < 0 {
            self.endByte()
        } else {
            self.sendBit()
        }
    }
    
    private func sendPulses() {
        if self.tCycle <= self.tStatesWait {
            return
        }
        
        self.tCycle -= self.tStatesWait
        
        if self.indexPulse < self.pulses!.count {
            let pulse = self.pulses![self.indexPulse]
            
            if let pulseTapeLevel = pulse.tapeLevel {
                self.lastLevel = pulseTapeLevel
            } else {
                self.lastLevel = self.lastLevel == .off ? .on : .off
            }

            self.ula.setTapeLevel(value: self.lastLevel.rawValue)
            
            self.tStatesWait = pulse.tStates
            
            self.indexPulse += 1
        } else {
            self.tStatesWait = 0
            self.pulses = nil
            
            self.afterPulsesCallback?()
        }
    }
}
