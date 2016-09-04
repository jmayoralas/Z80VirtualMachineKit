//
//  NSData+TapeLoader.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 26/8/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation

private enum TzxBlockId: UInt8 {
    case StandardSpeed = 0x10
}

extension NSData {

    private var tapeFormat: TapeFormat {
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
    
    // MARK: Public methods
    func getLocationFirstTapeDataBlock() -> Int {
        var firstDataBlock: Int = 0
        
        switch tapeFormat {
        case .Tap:
            firstDataBlock = 0
        case .Tzx:
            firstDataBlock = 0x0A
        }
        
        return firstDataBlock
        
    }
    
    func getTapeBlock(atLocation location: Int) throws -> TapeBlock? {
        let tapeBlock: TapeBlock?
        
        switch self.tapeFormat {
        case .Tap:
            tapeBlock = self.getTapTapeBlock(atLocation: location)
        case .Tzx:
            tapeBlock = try self.getTzxTapeBlock(atLocation: location)
        }
        
        return tapeBlock
    }
    
    // MARK: Private methods
    private func getNumber(location: Int, size: Int) -> Int {
        var number: Int = 0
        
        let range = NSRange(location: location, length: size)
        var bytes = [UInt8](repeatElement(0, count: size))
        
        self.getBytes(&bytes, range: range)
        
        for i in (0 ..< size).reversed() {
            number += Int(bytes[i]) << (8 * i)
        }
        
        return number
    }
    
    private func getBytes(location: Int, size: Int) -> [UInt8] {
        let range = NSRange(location: location, length: Int(size))
        var data = [UInt8](repeating: 0, count: Int(size))
        self.getBytes(&data, range: range)
        
        return data
    }
    
    private func getTapTapeBlock(atLocation location: Int) -> TapeBlock {
        let size = self.getNumber(location: location, size: 2)
        let data = self.getBytes(location: location + 2, size: size)
        
        return self.getTapTapeBlock(data: data)
    }
    
    private func getTapTapeBlock(data: [UInt8]) -> TapeBlock {
        let identifier: String
        let tapeBlockInfo: TapeBlockInfo
        
        if data[0] == 0x00 {
            let name : [UInt8] = Array(data[2...11])
            identifier = String(data: Data(name), encoding: String.Encoding.ascii)!
            tapeBlockInfo = kTapeBlockInfoStandardROMHeader
        } else {
            identifier = "[DATA]"
            tapeBlockInfo = kTapeBlockInfoStandardROMData
        }
        
        return TapeBlock(info: tapeBlockInfo, identifier: identifier, data: data)
    }

    private func getTzxTapeBlock(atLocation location: Int) throws -> TapeBlock? {
        let blockIdValue = UInt8(self.getNumber(location: location, size: 1))
        
        guard let blockId = TzxBlockId(rawValue: blockIdValue) else {
            throw TapeLoaderError.UnsupportedTapeBlockFormat(blockId: blockIdValue, location: location)
        }
        
        return nil
    }
}
