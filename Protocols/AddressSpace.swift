//
//  AddressSpace.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

protocol AddressSpace {
    var base_address: Int { get }
    var block_size: Int { get }
    
    func getBaseAddress() -> Int
    func getBlockSize() -> Int
}

extension AddressSpace {
    func getBaseAddress() -> Int {
        return base_address
    }
    
    func getBlockSize() -> Int {
        return block_size
    }
}