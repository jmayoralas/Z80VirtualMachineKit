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
    func hexStr() -> String {
        return "0x" + (String(NSString(format:"%02X", self)))
    }
}

