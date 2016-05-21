//
//  Ram.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

struct Ram: MemoryStorage {
    var buffer: [UInt8]
    var base_address: Int
    var block_size: Int
    var delegate: BusComponentWatcher?
    
    init(base_address: Int, block_size: Int) {
        self.base_address = base_address
        self.block_size = block_size
        buffer = [UInt8](count:block_size, repeatedValue: 0x00)
    }
}

struct Rom: MemoryStorage {
    var buffer: [UInt8]
    var base_address: Int
    var block_size: Int
    var delegate: BusComponentWatcher?
    
    init(base_address: Int, block_size: Int) {
        self.base_address = base_address
        self.block_size = block_size
        buffer = [UInt8](count:block_size, repeatedValue: 0x00)
    }
    
    func write(address: Int, value: UInt8) {}
}