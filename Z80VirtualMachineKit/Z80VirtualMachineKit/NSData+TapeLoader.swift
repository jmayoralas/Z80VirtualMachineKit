//
//  NSData+TapeLoader.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 26/8/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation

extension NSData {
    
    func getTapeBlock(atLocation location: Int) -> TapeBlock {
        let size = self.getNumber(location: location, size: 2)
        
        return TapeBlock(data: self.getBytes(location: location + 2, size: size))
    }
    
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
    
}
