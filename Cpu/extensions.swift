//
//  extensions.swift
//  			
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension SequenceType where Self.Generator.Element: Hashable {
    func freq() -> [Self.Generator.Element: Int] {
        return reduce([:]) { (accu: [Self.Generator.Element: Int], element) in
            var accu = accu
            accu[element] = accu[element]?.successor() ?? 1
            return accu
        }
    }
}

public extension UInt16 {
    func hexStr() -> String {
        return (String(NSString(format:"%04X", self)))
    }
    
    var high: UInt8 {
        return UInt8(self / 0x100)
    }
    
    var low: UInt8 {
        return UInt8(self % 0x100)
    }
}

public extension UInt8 {
    var parity: Int {
        let bit_array = self.binArray
        
        var result = 0
        if let ones_count = bit_array.freq()["1"] {
            if ones_count % 2 != 0 {
                result = 1
            }
        }
        
        return result
    }

    var comp2: Int {
        return self > 0x7F ? Int(Int(self) - 0xFF - 1) : Int(self)
    }
    
    func hexStr() -> String {
        return (String(NSString(format:"%02X", self)))
    }
    
    var binStr: String {
        var result = String(self, radix: 2)
        if result.characters.count < 8 {
            for _ in 0 ... 7 - result.characters.count {
                result.insert("0", atIndex: result.startIndex)
            }
        }
        return result
    }
    
    var binArray: Array<String> {
        var res = [String]()
        for caracter in self.binStr.characters {
            res.append(String(caracter))
        }
        return res
    }
    
    mutating func bit(index: Int, newVal: Int) -> UInt8 {
        if newVal == 1 { self.setBit(index) } else { self.resetBit(index) }
        
        return self
    }
    
    func bit(index: Int) -> Int {
        return (Int(self) >> index) & 0x01
    }
    
    mutating func setBit(index: Int) {
        self = self | UInt8(1 << index)
    }
    
    mutating func resetBit(index: Int) {
        self = self & ~UInt8(1 << index)
    }
    
    var high: UInt8 {
        return self & 0b11110000
    }
    
    var low: UInt8 {
        return self & 0b00001111
    }
}

public extension String {
    var binaryToDecimal: Int {
        return Int(strtoul(self, nil, 2))
    }
}
