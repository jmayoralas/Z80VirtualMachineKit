//
//  TapeLoader.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 3/8/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation

public enum TapeLoaderError: Error {
    case FileNotFound
    case OutOfData
    case NoTapeOpened
    case EndOfTape
}

enum TapeBlockType: UInt8 {
    case Header = 0x00
    case Data = 0xFF
}

struct TapeBlock {
    var size : Int {
        get {
            // a tape block has a UInt16 header with the data buffer size, and the data buffer
            return MemoryLayout<UInt16>.size + data.count
        }
    }

    var type: TapeBlockType
    var identifier: String
    var data: [UInt8]
}

final class TapeLoader {
    private var blocks: [TapeBlock]?
    
    private var index = 0
    
    func open(path: String) throws {
        if let buffer = NSData(contentsOfFile: path) {
            var location = 0
            
            blocks = [TapeBlock]()
            
            while (location < buffer.length) {
                let tapeBlock = buffer.getTapeBlock(atLocation: location)
                blocks!.append(tapeBlock)
                
                location += tapeBlock.size
            }
            
            index = 0
        } else {
            throw TapeLoaderError.FileNotFound
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
