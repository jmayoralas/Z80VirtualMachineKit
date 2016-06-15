//
//  Rom.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 15/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

final class Rom: Ram {
    override func write(address: UInt16, value: UInt8) {
        // do nothing
    }
    
    func loadData(data: [UInt8], atAddress address: Int) throws
    {
        guard data.count <= self.block_size else {
            throw RomErrors.BufferLimitReach
        }
        
        for i in 0..<data.count {
            buffer[Int(address) - Int(self.base_address) + i] = data[i]
            delegate?.MemoryWriteAtAddress?(Int(address), byte: data[i])
        }
    }
}