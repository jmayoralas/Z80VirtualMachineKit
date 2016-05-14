//
//  Ula.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 12/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

class ULAMemory : Ram {
    convenience init() {
        self.init(base_address: 0x4000, block_size: 0x4000)
    }
    override func write(address: UInt16, value: UInt8) {
        super.write(address, value: value)
    }
    
    func memoryWrite(address: UInt16, value: UInt8) {
        NSLog("Writing to ULAMemory address: %@, value: %@", address, value.hexStr())
    }
}

class ULAIo : BusComponent {
    convenience init() {
        self.init(base_address: 0xFE, block_size: 1)
    }
    
    override func read(address: UInt16) -> UInt8 {
        return ioRead(address)
    }
    
    override func write(address: UInt16, value: UInt8) {
        ioWrite(address, value: value)
    }
    
    func ioRead(address: UInt16) -> UInt8 {
        NSLog("Reading from ULAIo address: %@", address)
        return 0xFF
    }
    
    func ioWrite(address: UInt16, value: UInt8)  {
        NSLog("Writing to ULAIo address: %@, value: %@", address, value.hexStr())
    }
}

final class Ula {
    let memory = ULAMemory()
    let io = ULAIo()
}