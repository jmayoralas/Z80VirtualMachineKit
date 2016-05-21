//
//  Bus16.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

struct Bus16: BusComponent, BusComponentCollection {
    var base_address: Int = 0x0000
    var block_size: Int = 0x10000
    
    var bus_components = [BusComponent]()
    var paged_components: [BusComponent]
    var delegate: BusComponentWatcher?
    
    init() {
        let dummy_component = DummyComponent()
        paged_components = [BusComponent](count: 64, repeatedValue: dummy_component)
    }
    
    mutating func onComponentsUpdated() {
        for component in self.bus_components {
            let start = Int(component.getBaseAddress() / 1024)
            let end = start + component.getBlockSize() / 1024 - 1
            
            for i in start...end {
                paged_components[i] = component
            }
        }
    }
    
    func read(address: Int) -> UInt8 {
        return paged_components[address / 1024].read(address)
    }
    
    mutating func write(address: Int, value: UInt8) {
        paged_components[address / 1024].write(address, value: value)
    }
    
    func dump(address: Int, count: Int) -> [UInt8] {
        var index_component = (address & 0xFFFF) / 1024
        var address = address
        var result = [UInt8]()
        
        while result.count < count {
            result = result + paged_components[index_component].dump(address, count: count - result.count)
            index_component += 1
            address += result.count
        }
        
        return result
    }
}

struct IoBus: BusComponent, BusComponentCollection {
    var base_address: Int = 0
    var block_size: Int = 0x100
    
    var bus_components = [BusComponent]()
    var paged_components: [BusComponent]
    var delegate: BusComponentWatcher?
    
    init() {
        let dummy_component = DummyComponent()
        paged_components = [BusComponent](count: block_size, repeatedValue: dummy_component)
    }
    
    mutating func onComponentsUpdated() {
        for component in self.bus_components {
            paged_components[component.base_address] = component
        }
    }
    
    func read(address: Int) -> UInt8 {
        return paged_components[address & 0x00FF].read(address)
    }
    
    mutating func write(address: Int, value: UInt8) {
        paged_components[address & 0x00FF].write(address, value: value)
    }
}