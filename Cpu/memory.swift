//
//  memory.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 9/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

class Memory {
    var address: UInt16 = 0
    var data = [UInt8](count: 0x10000, repeatedValue: 0)
    
    init() {

    }
}
