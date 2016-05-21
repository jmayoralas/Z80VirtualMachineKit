//
//  IOStorage.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

protocol IOStorage: BusComponent {
    func ioRead(address: Int) -> UInt8
    mutating func ioWrite(address: Int, value: UInt8)
}

extension IOStorage {
    func read(address: Int) -> UInt8 {
        return ioRead(address)
    }
    
    mutating func write(address: Int, value: UInt8) {
        ioWrite(address, value: value)
        delegate?.onWrite(address, value: value)
    }
}