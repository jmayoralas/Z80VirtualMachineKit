//
//  Ram.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 1/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

class Ram : BusComponent {
    var buffer : [UInt8]
    
    override init(base_address: UInt16, block_size: Int) {
        buffer = Array(count: block_size, repeatedValue: 0x00)
        
        super.init(base_address: base_address, block_size: block_size)
    }
    
    override func read(address: UInt16) -> UInt8 {
        return buffer[Int(address) - Int(self.base_address)]
    }
    
    override func write(address: UInt16, value: UInt8) {
        buffer[Int(address) - Int(self.base_address)] = value
    }
}