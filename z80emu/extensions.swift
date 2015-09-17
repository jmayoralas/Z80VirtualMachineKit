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
}

