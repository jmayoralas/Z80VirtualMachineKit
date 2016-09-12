//
//  TapeLoader.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 3/8/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation

public enum TapeLoaderError: Error, CustomStringConvertible {
    case FileNotFound(path: String)
    case OutOfData
    case NoTapeOpened
    case EndOfTape
    case UnsupportedTapeBlockFormat(blockId: UInt8, location: Int)
    case DataIncoherent(blockId: UInt8, location: Int)
    
    public var description: String {
        let description: String
        
        switch self {
        case .FileNotFound(let path):
            description = String(format: "File not found: %@", path)
        case .OutOfData:
            description = "Out of data in tape block"
        case .NoTapeOpened:
            description = "No tape has been opened"
        case .EndOfTape:
            description = "Reached the end of tape"
        case .UnsupportedTapeBlockFormat(let blockId, let location):
            description = String(format: "Unsupported tape block id. Location %d, block id 0x%@", location, blockId.hexStr())
        case .DataIncoherent(let blockId, let location):
            description = String(format: "Incoherent data found. Location %d for block id 0x%@", location, blockId.hexStr())
        }
        
        return description
    }
}

public enum TapeBlockType: Int, CustomStringConvertible {
    case ProgramHeader = 0
    case NumberArrayHeader
    case CharacterArrayHeader
    case BytesHeader
    case Dummy = 99
    case Data
    case TzxTone
    
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
            case .Dummy:
                fallthrough
            case .Data:
                description = ""
            case .TzxTone:
                description = "Pure tone"
            }
            
            return description
        }
    }
}

enum TapeFormat: UInt8 {
    case Tap
    case Tzx
}

struct TapeBlockTimingInfo {
    var pilotPulseLength: Int
    var syncFirstPulseLength: Int
    var syncSecondPulseLength: Int
    var resetBitPulseLength: Int
    var setBitPulseLength: Int
    var pilotTonePulsesCount: Int
    var pauseAfterBlock: Int
}

let kTapeBlockTimingInfoStandardROMHeader = TapeBlockTimingInfo(
    pilotPulseLength: 2168,
    syncFirstPulseLength: 667,
    syncSecondPulseLength: 735,
    resetBitPulseLength: 855,
    setBitPulseLength: 1710,
    pilotTonePulsesCount: 8063,
    pauseAfterBlock: 1000
)

let kTapeBlockTimingInfoStandardROMData = TapeBlockTimingInfo(
    pilotPulseLength: 2168,
    syncFirstPulseLength: 667,
    syncSecondPulseLength: 735,
    resetBitPulseLength: 855,
    setBitPulseLength: 1710,
    pilotTonePulsesCount: 3223,
    pauseAfterBlock: 1000
)

let kDummyTapeBlockIdentifier = "dummy"
let kPauseTapeBlockIdentifier = "pause"

struct TapeBlock {
    var size : Int
    var timingInfo: TapeBlockTimingInfo
    var identifier: String
    var type: TapeBlockType
    
    let data: [UInt8]
    
    init(size: Int, timingInfo: TapeBlockTimingInfo, identifier: String, type: TapeBlockType, data: [UInt8]) {
        self.size = size
        self.timingInfo = timingInfo
        self.identifier = identifier
        self.type = type
        self.data = data
    }
    
    init(size: Int) {
        self.size = size
        self.timingInfo = kTapeBlockTimingInfoStandardROMData
        self.identifier = kDummyTapeBlockIdentifier
        self.type = .Dummy
        self.data = []
    }
}

final class TapeLoader {
    var eof: Bool {
        get {
            guard let blocks = self.blocks else {
                return true
            }
            
            return self.index == blocks.count
        }
    }
    
    private var blocks: [TapeBlock]?
    
    private var index = 0
    
    func open(path: String) throws {
        if let buffer = TapeData(contentsOfFile: path) {
            
            blocks = []
            
            while (!buffer.eof) {
                let tapeBlock = try buffer.getNextTapeBlock()
                
                if tapeBlock.identifier != kDummyTapeBlockIdentifier {
                    blocks!.append(tapeBlock)
                }
            }
            
            index = 0
            
        } else {
            throw TapeLoaderError.FileNotFound(path: path)
        }
    }
    
    func blockCount() -> Int {
        let count: Int
        
        if let blocks = self.blocks {
            count = blocks.count
        } else {
            count = 0
        }
        
        return count
    }
    
    func readBlock() throws -> TapeBlock? {
        var block: TapeBlock? = nil
        
        if let blocks = self.blocks {
            guard !self.eof else {
                throw TapeLoaderError.EndOfTape
            }
            
            block = blocks[index]
            
            index += 1
        }
        
        return block
    }
    
    func getBlockDirectory() throws -> [TapeBlock] {
        guard let blocks = self.blocks else {
            throw TapeLoaderError.NoTapeOpened
        }
        
        return blocks
    }
    
    func setCurrentBlock(index: Int) throws {
        guard let blocks = self.blocks else {
            throw TapeLoaderError.NoTapeOpened
        }
        
        guard index < blocks.count else {
            throw TapeLoaderError.EndOfTape
        }
        
        self.index = index
    }
    
    func rewind() {
        self.index = 0
    }
    
    func close() {
        blocks = nil
    }
}
