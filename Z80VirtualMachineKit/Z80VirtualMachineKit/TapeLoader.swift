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
        }
        
        return description
    }
}

enum TapeFormat: UInt8 {
    case Tap
    case Tzx
}

struct TapeBlockInfo {
    var pilotPulseLength: Int
    var syncFirstPulseLength: Int
    var syncSecondPulseLength: Int
    var resetBitPulseLength: Int
    var setBitPulseLength: Int
    var pilotTonePulsesCount: Int
    var pauseAfterBlock: Int
}

let kTapeBlockInfoStandardROMHeader = TapeBlockInfo(
    pilotPulseLength: 2168,
    syncFirstPulseLength: 667,
    syncSecondPulseLength: 735,
    resetBitPulseLength: 855,
    setBitPulseLength: 1710,
    pilotTonePulsesCount: 8063,
    pauseAfterBlock: 1000
)

let kTapeBlockInfoStandardROMData = TapeBlockInfo(
    pilotPulseLength: 2168,
    syncFirstPulseLength: 667,
    syncSecondPulseLength: 735,
    resetBitPulseLength: 855,
    setBitPulseLength: 1710,
    pilotTonePulsesCount: 3223,
    pauseAfterBlock: 1000
)

struct TapeBlock {
    var size : Int {
        get {
            // a tape block has a UInt16 header with the data buffer size, and the data buffer
            return MemoryLayout<UInt16>.size + data.count
        }
    }

    let info: TapeBlockInfo
    let identifier: String
    let data: [UInt8]
}

final class TapeLoader {
    private var blocks: [TapeBlock]?
    
    private var index = 0
    
    func open(path: String) throws {
        if let buffer = NSData(contentsOfFile: path) {
            var location = buffer.getLocationFirstTapeDataBlock()
            
            blocks = []
            
            while (location < buffer.length) {
                if let tapeBlock = try buffer.getTapeBlock(atLocation: location) {
                    blocks!.append(tapeBlock)
                    location += tapeBlock.size
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
            guard index < blocks.count else {
                throw TapeLoaderError.OutOfData
            }
            
            block = blocks[index]
            
            index += 1
        }
        
        return block
    }
    
    func rewind() {
        self.index = 0
    }
    
    func close() {
        blocks = nil
    }
}
