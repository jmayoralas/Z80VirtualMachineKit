//
//  DataStorage.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

protocol MemoryStorage: BusComponent {
    var buffer: [UInt8] { get set }
}

extension MemoryStorage {
    func read(address: Int) -> UInt8 {
        return buffer[address - base_address]
    }
    
    mutating func write(address: Int, value: UInt8) {
        buffer[address - base_address] = value
        delegate?.onWrite(address, value: value)
    }
    
    func dump(address: Int, count: Int) -> [UInt8] {
        let topAddress = Int(base_address) + block_size - 1
        
        let myFromAddress = (address < 0 ? 0 : address) - Int(base_address)
        var myToAddress = address + (count > buffer.count ? buffer.count : count) - 1 - Int(base_address)
        myToAddress = myToAddress > topAddress ? topAddress : myToAddress
        
        return Array(buffer[myFromAddress...myToAddress])
    }
}