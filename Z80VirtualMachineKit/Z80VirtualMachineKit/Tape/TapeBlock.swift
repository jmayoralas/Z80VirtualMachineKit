//
//  TapeBlock.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 13/9/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

enum TapeLevel: Int {
    case off = 0
    case on = 1
}

struct Pulse {
    var tapeLevel: TapeLevel?
    var tStates: Int
}

enum TapeBlockType {
    case Pulse
    case Data
}

public enum TapeBlockDescription: Int, CustomStringConvertible {
    case ProgramHeader = 0
    case NumberArrayHeader
    case CharacterArrayHeader
    case BytesHeader
    
    public var description: String {
        get {
            let description: String
            
            switch self {
            case .ProgramHeader:
                description = "Program"
            case .NumberArrayHeader:
                description = "Number array"
            case .CharacterArrayHeader:
                description = "Character array"
            case .BytesHeader:
                description = "Bytes"
            }
            
            return description
        }
    }
}

protocol TapeBlockPart: CustomStringConvertible {
    var type: TapeBlockType { get }
    var size: Int { get }
}

private let kEndPulseSequence = Pulse(tapeLevel: nil, tStates: 0)

struct TapeBlockPartPulse : TapeBlockPart {
    var type: TapeBlockType = .Pulse
    var size: Int
    
    var description: String {
        get {
            return String(format: "Pulse block. %d pulses.", self.pulses.count - 1)
        }
    }
    
    private let pulses: [Pulse]
    
    init(size: Int, pulsesCount: Int, tStatesDuration: Int) {
        self.size = size
        
        var pulses = [Pulse]()
        
        for _ in 1 ... pulsesCount {
            pulses.append(Pulse(tapeLevel: nil, tStates: tStatesDuration))
        }
        
        pulses.append(kEndPulseSequence)
        
        self.pulses = pulses
    }
    
    init(size: Int, firstPulseTStates: Int, secondPulseTStates: Int) {
        self.size = size
        
        self.pulses = [
            Pulse(tapeLevel: .off, tStates: firstPulseTStates),
            Pulse(tapeLevel: .on, tStates: secondPulseTStates),
            kEndPulseSequence
        ]
    }
    
    func getPulses() -> [Pulse] {
        return self.pulses
    }
}

struct TapeBlockPartData: TapeBlockPart {
    var type: TapeBlockType = .Data
    var size: Int
    
    var description: String {
        get {
            return String(format: "Pure data block. %d bytes", self.data.count)
        }
    }
    
    private var resetBitPulseLength: Int
    private var setBitPulseLength: Int
    
    private var usedBitsLastByte: Int
    
    var data: [UInt8]
    
    init(size: Int, resetBitPulseLength: Int, setBitPulseLength: Int, usedBitsLastByte: Int, data: [UInt8]) {
        self.size = size
        self.resetBitPulseLength = resetBitPulseLength
        self.setBitPulseLength = setBitPulseLength
        self.usedBitsLastByte = usedBitsLastByte
        self.data = data
    }
    
    func getPulses(byteIndex: Int) -> [Pulse] {
        let lastUsedBit = byteIndex < self.data.count - 1 ? 0 : 8 - self.usedBitsLastByte
        
        var pulses = [Pulse]()
        
        guard lastUsedBit < 8 else {
            return pulses
        }
        
        for bit in (lastUsedBit ... 7).reversed() {
            pulses.append(contentsOf: self.getBitPulses(byteIndex: byteIndex, bitIndex: bit))
        }
        
        pulses.append(kEndPulseSequence)
        
        return pulses
    }
    
    private func getBitPulses(byteIndex: Int, bitIndex: Int) -> [Pulse] {
        let bitToSend = self.data[byteIndex].bit(bitIndex)
        
        let bitTStates = bitToSend == 0 ? self.resetBitPulseLength : self.setBitPulseLength
        
        return [
            Pulse(tapeLevel: .off, tStates: bitTStates),
            Pulse(tapeLevel: .on, tStates: bitTStates),
        ]
    }
}

struct TapeBlock: CustomStringConvertible {
    var description: String
    var parts: [TapeBlockPart]
    
    var pauseAfterBlock: Int?
    
    var size: Int = 0
    
    init(description: String, parts: [TapeBlockPart], pauseAfterBlock: Int) {
        self.description = description
        self.parts = parts
        self.pauseAfterBlock = pauseAfterBlock
        
        self.size = self.getPartsSize()
    }
    
    func getPartsSize() -> Int {
        var size: Int = 0
        
        for part in self.parts {
            size += part.size
        }
        
        return size
    }
}
