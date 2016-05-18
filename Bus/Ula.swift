//
//  Ula.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 12/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

protocol UlaDelegate {
    func memoryWrite(address: UInt16, value: UInt8)
    func ioWrite(address: UInt16, value: UInt8)
    func ioRead(address: UInt16) -> UInt8
}

class ULAMemory : Ram {
    let ulaDelegate: UlaDelegate
    
    init(delegate: UlaDelegate) {
        self.ulaDelegate = delegate
        super.init(base_address: 0x4000, block_size: 0x4000)
    }
    
    override func write(address: UInt16, value: UInt8) {
        super.write(address, value: value)
        ulaDelegate.memoryWrite(address, value: value)
    }
}

class ULAIo : CBusComponent {
    let ulaDelegate: UlaDelegate
    
    init(delegate: UlaDelegate) {
        self.ulaDelegate = delegate
        super.init(base_address: 0xFE, block_size: 1)
    }
    
    override func read(address: UInt16) -> UInt8 {
        return ulaDelegate.ioRead(address)
    }
    
    override func write(address: UInt16, value: UInt8) {
        ulaDelegate.ioWrite(address, value: value)
    }
}

final class Ula: UlaDelegate {
    var memory: ULAMemory!
    var io: ULAIo!
    
    init() {
        memory = ULAMemory(delegate: self)
        io = ULAIo(delegate: self)
    }
    
    func memoryWrite(address: UInt16, value: UInt8) {
        NSLog("Writing to ULAMemory address: %@, value: %@", address.hexStr(), value.hexStr())
        NSLog("in ula memory: %@", memory.read(address).hexStr())
    }
    
    func ioRead(address: UInt16) -> UInt8 {
        NSLog("Reading from ULAIo address: %@", address.hexStr())
        return 0xFF
    }
    
    func ioWrite(address: UInt16, value: UInt8)  {
        NSLog("Writing to ULAIo address: %@, value: %@", address.hexStr(), value.hexStr())
    }
}