//
//  DummyComponent.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

struct DummyComponent: BusComponent {
    var base_address: Int = 0
    var block_size: Int = 0
    var delegate: BusComponentWatcher?
}