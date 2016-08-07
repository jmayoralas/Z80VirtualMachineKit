//
//  TapeLoader.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 3/8/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation

enum TapeLoaderErrors: ErrorProtocol {
    case FileNotFound
    case OutOfData
}

struct TapeBlock {
    var size : Int {
        get {
            // a tape block has a UInt16 header with the data buffer size, and the data buffer
            return sizeof(UInt16.self) + data.count
        }
    }
    
    var data: [UInt8]
}

private extension NSData {
    func getTapeBlock(atLocation location: Int) -> TapeBlock {
        var size: UInt16 = 0
        var range = NSRange(location: location, length: sizeof(UInt16.self))
        self.getBytes(&size, range: range)
        
        range = NSRange(location: location + sizeof(UInt16.self), length: Int(size))
        var tapeBlock = TapeBlock(data: [UInt8](repeating: 0, count: Int(size)))
        self.getBytes(&tapeBlock.data, range: range)
        
        return tapeBlock
    }
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
        if blocks != nil {
            blocks = nil
        }
    }
}
