//
//  UlaIO.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 9/6/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

final class ULAIo : BusComponent {
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
