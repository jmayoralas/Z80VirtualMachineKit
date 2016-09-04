//
//  NSData+TapeLoader.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 26/8/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation

extension NSData {
    
    func getNumber(location: Int, size: Int) -> Int {
        var number: Int = 0
        
        let range = NSRange(location: location, length: size)
        var bytes = [UInt8](repeatElement(0, count: size))
        
        self.getBytes(&bytes, range: range)
        
        for i in (0 ..< size).reversed() {
            number += Int(bytes[i]) << (8 * i)
        }
        
        return number
    }
    
    func getBytes(location: Int, size: Int) -> [UInt8] {
        let range = NSRange(location: location, length: Int(size))
        var data = [UInt8](repeating: 0, count: Int(size))
        self.getBytes(&data, range: range)
        
        return data
    }
    
    func getTapeBlock(atLocation location: Int) -> TapeBlock {
        let size = self.getNumber(location: location, size: 2)
        let data = self.getBytes(location: location + 2, size: size)
        
        return self.getTapeBlock(data: data)
    }
    
    func getTapeBlock(data: [UInt8]) -> TapeBlock {
        let type = data[0] == 0x00 ? TapeBlockType.Header : TapeBlockType.Data
        let identifier: String
        let tapeBlockInfo: TapeBlockInfo
        
        if type == .Header {
            let name : [UInt8] = Array(data[2...11])
            identifier = String(data: Data(name), encoding: String.Encoding.ascii)!
            tapeBlockInfo = kTapeBlockInfoStandardROMHeader
        } else {
            identifier = "[DATA]"
            tapeBlockInfo = kTapeBlockInfoStandardROMData
        }
        
        return TapeBlock(info: tapeBlockInfo, identifier: identifier, data: data)
    }
    
}
