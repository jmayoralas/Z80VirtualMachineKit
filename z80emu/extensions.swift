//
//  extensions.swift
//  			
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension UInt16 {
    func hexStr() -> String {
        return "0x" + (String(NSString(format:"%04X", self)))
    }
}

extension UInt8 {
    var comp2: Int {
        return self > 0x7F ? Int(Int(self) - 0xFF - 1) : Int(self)
    }
    
    func hexStr() -> String {
        return "0x" + (String(NSString(format:"%02X", self)))
    }
    
    var binStr: String {
        return String(self, radix: 2)
    }
    
    var binArray: Array<String> {
        var res = [String]()
        for caracter in self.binStr.characters {
            res.append(String(caracter))
        }
        
        while res.count < 8 {
            res.insert("0", atIndex: 0)
        }
        
        return res
    }
    
    var high: UInt8 {
        return self & 0b11110000
    }
    
    var low: UInt8 {
        return self & 0b00001111
    }
}

extension String {
    var binaryToDecimal: Int {
        return Int(strtoul(self, nil, 2))
    }
}
