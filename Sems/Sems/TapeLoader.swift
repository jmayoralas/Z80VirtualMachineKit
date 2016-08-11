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
    case TzxBlockIdNotSupported
}

struct TapeBlock {
    var format: TapeFormat
    
    var size : Int {
        get {
            let size: Int
            
            switch format {
            case .Tap:
                // a TAP block has a UInt16 header with the data buffer size, and the data buffer
                size = sizeof(UInt16.self) + data.count
            case .Tzx:
                // a TZX block has header with UInt8 with the block ID a UInt16 with the pause after this block, a UInt16 with the data buffer size, and the data buffer
                size =  sizeof(UInt8.self) + sizeof(UInt16.self) + sizeof(UInt16.self) + data.count
            }
            
            return size
        }
    }
    
    var data: [UInt8]
}

enum TapeFormat {
    case Tap
    case Tzx
}

private let tzxDataBlocksRecognized: Set<UInt8> = [0x10, 0x14]

private struct TzxBlockFormat {
    let id: UInt8
    var sizeOffset: Int
    let numBytes: Int
    let paramLength: Int
}

private let tzxBlocks: [TzxBlockFormat] = [
    TzxBlockFormat(
        id: 0x10,
        sizeOffset: sizeof(UInt8.self) + sizeof(UInt16.self),
        numBytes: sizeof(UInt16.self),
        paramLength: 0),
    TzxBlockFormat(
        id: 0x14,
        sizeOffset: 2 * sizeof(UInt8.self) + 3 * sizeof(UInt16.self),
        numBytes: sizeof(UInt16.self),
        paramLength: 0),
    TzxBlockFormat(
        id: 0x12,
        sizeOffset: -1,
        numBytes: sizeof(UInt16.self) + sizeof(UInt16.self),
        paramLength: 0
    ),
    TzxBlockFormat(
        id: 0x13,
        sizeOffset: 1,
        numBytes: sizeof(UInt8.self),
        paramLength: sizeof(UInt16.self)
    ),
    TzxBlockFormat(
        id: 0x21,
        sizeOffset: sizeof(UInt8.self),
        numBytes: sizeof(UInt8.self),
        paramLength: 0
    ),
    TzxBlockFormat(
        id: 0x24,
        sizeOffset: -1,
        numBytes: sizeof(UInt16.self),
        paramLength: 0
    ),
    TzxBlockFormat(
        id: 0x25,
        sizeOffset: -1,
        numBytes: 0,
        paramLength: 0
    ),
    TzxBlockFormat(
        id: 0x32,
        sizeOffset: sizeof(UInt8.self),
        numBytes: sizeof(UInt16.self),
        paramLength: 0
    )
]

private extension NSData {
    var tapeFormat: TapeFormat {
        get {
            // get first 8 bytes and search for TZX signature
            let range = NSRange(location: 0, length: 7)
            var tapeFormat: TapeFormat = .Tap
            
            var signatureBytes = [UInt8](repeating: 0, count: 7)
            self.getBytes(&signatureBytes, range: range)
            
            if let signature = String(bytes: signatureBytes, encoding: String.Encoding.utf8) {
                if signature == "ZXTape!" {
                    tapeFormat = .Tzx
                }
            }
            
            return tapeFormat
        }
    }
    
    func getTapeFirstDataBlockLocation() throws -> Int {
        var firstDataBlock: Int = 0
        
        switch tapeFormat {
        case .Tap:
            firstDataBlock = 0
        case .Tzx:
            firstDataBlock = 0x0A
            let _ = try getTzxNextDataBlockLocation(fromLocation: &firstDataBlock)
        }
        
        return firstDataBlock

    }
    
    func getTapeNextDataBlockLocation(fromLocation: Int) throws -> Int {
        var location = fromLocation
        
        switch tapeFormat {
        case .Tap:
            location += getTapBlockSize(location: location)
        case .Tzx:
            let _ = try getTzxNextDataBlockLocation(fromLocation: &location)
        }
        
        return location
    }
    
    func getTapeBlock(location: inout Int) throws -> TapeBlock {
        var tapeBlock: TapeBlock!
        
        switch tapeFormat {
        case .Tap:
            tapeBlock = getTapBlock(location: &location)
        case .Tzx:
            tapeBlock = try getTzxBlock(location: &location)
        }
        
        return tapeBlock
    }
    
    // MARK: TZX format handler
    private func getTzxNextDataBlockLocation(fromLocation location: inout Int) throws -> UInt8 {
        var dataBlockFound = false
        var blockId: UInt8!
        
        while !dataBlockFound && location < self.length {
            blockId = getTzxBlockId(location: location)
            
            if tzxDataBlocksRecognized.contains(blockId) {
                dataBlockFound = true
            } else {
                try getTzxBlockSize(location: &location, blockId: blockId)
            }
        }
        
        guard dataBlockFound else {
            throw TapeLoaderErrors.OutOfData
        }
        
        return blockId
    }
    
    private func getTzxBlockId(location: Int) -> UInt8 {
        var blockId: UInt8 = 0
        let range = NSRange(location: location, length: sizeof(UInt8.self))
        self.getBytes(&blockId, range: range)
        
        return blockId
    }
    
    private func getTzxBlockSize(location: inout Int, blockId: UInt8) throws {
        var thisTzxBlock = try getTzxBlockFormat(id: blockId)
        
        var size: Int = 0
        
        if thisTzxBlock.sizeOffset > 0 {
            switch thisTzxBlock.numBytes {
            case 1:
                var sizeUInt8: UInt8 = 0
                let range = NSRange(location: location + thisTzxBlock.sizeOffset, length: sizeof(UInt8.self))
                self.getBytes(&sizeUInt8, range: range)
                
                size = Int(sizeUInt8)
            default:
                var sizeUInt16: UInt16 = 0
                let range = NSRange(location: location + thisTzxBlock.sizeOffset, length: sizeof(UInt16.self))
                self.getBytes(&sizeUInt16, range: range)
                
                size = Int(sizeUInt16)
            }
        } else {
            thisTzxBlock.sizeOffset = 1
        }
        
        if thisTzxBlock.paramLength != 0 {
            size = size * thisTzxBlock.paramLength
        }
        location += size + thisTzxBlock.numBytes + thisTzxBlock.sizeOffset
    }
    
    private func getTzxBlock(location: inout Int) throws -> TapeBlock {
        var tapeBlock: TapeBlock!
        
        // let blockId = getTzxBlockId(location: location)
        let blockId = try getTzxNextDataBlockLocation(fromLocation: &location)
        
        let thisTzxBlockFormat = try getTzxBlockFormat(id: blockId)
        
        location += thisTzxBlockFormat.sizeOffset
        tapeBlock = getTapBlock(location: &location)
        tapeBlock.format = .Tzx
/*
        switch blockId {
        case 0x10:
            location += sizeof(UInt8.self) + sizeof(UInt16.self)
            tapeBlock = getTapBlock(location: &location)
            tapeBlock.format = .Tzx
        case 0x14:
            location += sizeof(UInt8.self) + sizeof(UInt16.self)
            tapeBlock = getTapBlock(location: &location)
            tapeBlock.format = .Tzx
        default:
            throw TapeLoaderErrors.TzxBlockIdNotSupported
        }
*/
        return tapeBlock
    }
    
    // MARK: TAP format handler
    private func getTapBlockSize(location: Int) -> Int {
        var size: UInt16 = 0
        let range = NSRange(location: location, length: sizeof(UInt16.self))
        self.getBytes(&size, range: range)
        
        return Int(size)
    }
    
    private func getTapBlock(location: inout Int) -> TapeBlock {
        let size = getTapBlockSize(location: location)
        
        let range = NSRange(location: location + sizeof(UInt16.self), length: size)
        var tapeBlock = TapeBlock(format: .Tap, data: [UInt8](repeating: 0, count: size))
        self.getBytes(&tapeBlock.data, range: range)
        
        location += sizeof(UInt16.self) + size
        
        return tapeBlock
    }
    
    private func getTzxBlockFormat(id: UInt8) throws -> TzxBlockFormat {
        var thisTzxBlock = TzxBlockFormat(id: 0, sizeOffset: 0, numBytes: 0, paramLength: 0)
        
        for tzxBlockFormat in tzxBlocks {
            if tzxBlockFormat.id == id {
                thisTzxBlock = tzxBlockFormat
                break
            }
        }
        
        guard thisTzxBlock.id != 0 else {
            throw TapeLoaderErrors.TzxBlockIdNotSupported
        }
        
        return thisTzxBlock
    }
    
    
}

final class TapeLoader {
    private var blocks: [TapeBlock]?
    
    private var index = 0
    
    func open(path: String) throws {
        if let buffer = NSData(contentsOfFile: path) {
            var location = try buffer.getTapeFirstDataBlockLocation()
            
            blocks = [TapeBlock]()
            
            while (location < buffer.length) {
                let tapeBlock = try buffer.getTapeBlock(location: &location)
                blocks!.append(tapeBlock)
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
