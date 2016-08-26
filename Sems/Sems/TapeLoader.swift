//
//  TapeLoader.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 3/8/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation

enum TapeLoaderErrors: Error {
    case FileNotFound
    case OutOfData
}

struct TapeBlock {
    var size : Int {
        get {
            // a tape block has a UInt16 header with the data buffer size, and the data buffer
            return MemoryLayout<UInt16>.size + data.count
        }
    }

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
            throw TapeLoaderErrors.FileNotFound
        }
    }
    
    func readBlock() throws -> TapeBlock? {
        var block: TapeBlock? = nil
        
        if let blocks = self.blocks {
            guard index < blocks.count else {
                throw TapeLoaderErrors.OutOfData
            }
            
            block = blocks[index]
            
            index += 1
        }
        
        return block
    }
    
    func close() {
        blocks = nil
    }
}
