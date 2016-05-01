//
//  BusComponent.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 1/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

class BusComponent : BusComponentProtocol {
    var base_address : UInt16
    var block_size : Int
    
    init(base_address: UInt16, block_size: Int) {
        self.base_address = base_address
        self.block_size = block_size
    }
    
    func read(address: UInt16) -> UInt8 {
        return 0xFF
    }
    
    func write(address: UInt16, value: UInt8) {
    }
}