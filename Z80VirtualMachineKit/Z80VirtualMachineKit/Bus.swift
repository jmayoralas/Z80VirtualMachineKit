//
//  Bus.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 1/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

class Bus : BusComponent {
    private var bus_components = [BusComponent]()
    
    func addBusComponent(bus_component: BusComponent) {
        bus_components.append(bus_component)
        onComponentsUpdated()
    }
    
    func deleteBusComponent(bus_component: BusComponent) {
        for (index, component) in bus_components.enumerate() {
            if component === bus_component {
                bus_components.removeAtIndex(index)
                onComponentsUpdated()
                return
            }
        }
    }
    
    func onComponentsUpdated() {
        
    }
}

class Bus16 : Bus {
    private var paged_components : [BusComponent]
    
    init() {
        let dummy_component = BusComponent(base_address: 0x0000, block_size: 0x0000)
        paged_components = Array(count: 64, repeatedValue: dummy_component)
        
        super.init(base_address: 0x0000, block_size: 0x10000)
    }
    
    override func onComponentsUpdated() {
        for component in bus_components {
            let start = Int(component.getBaseAddress() / 1024)
            let end = start + component.getBlockSize() / 1024 - 1
            
            for i in start...end {
                paged_components[i] = component
            }
        }
    }
    
    override func write(address: UInt16, value: UInt8) {
        let index_component = (Int(address) & 0xFFFF) / 1024
        
        if index_component < paged_components.count {
            paged_components[index_component].write(address, value: value)
        }
    }
    
    override func read(address: UInt16) -> UInt8 {
        let index_component = (Int(address) & 0xFFFF) / 1024
        
        return (index_component < paged_components.count) ? paged_components[index_component].read(address) : 0xFF
    }
}