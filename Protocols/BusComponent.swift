//
//  BusComponent.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

protocol BusComponentWatcher {
    mutating func onWrite(address: Int, value: UInt8)
}

protocol BusComponent: AddressSpace {
    var delegate: BusComponentWatcher? { get set }
    
    func read(address: Int) -> UInt8
    mutating func write(address: Int, value: UInt8)
    func dump(address: Int, count: Int) -> [UInt8]
}

extension BusComponent {
    func read(address: Int) -> UInt8 {
        return 0xFF
    }
    
    mutating func write(address: Int, value: UInt8) {}
    
    func dump(address: Int, count: Int) -> [UInt8] {
        return [UInt8](count: count, repeatedValue: 0xFF)
    }
}

protocol BusComponentCollection {
    var bus_components: [BusComponent] { get set }
    
    mutating func addBusComponent(bus_component: BusComponent)
    mutating func onComponentsUpdated()
}

extension BusComponentCollection {
    mutating func addBusComponent(bus_component: BusComponent) {
        bus_components.append(bus_component)
        onComponentsUpdated()
    }
    
    mutating func onComponentsUpdated() {}
}