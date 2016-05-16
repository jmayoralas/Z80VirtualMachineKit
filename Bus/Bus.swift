//
//  Bus.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 1/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

class BusBase : BusComponent {
    var bus_components = [BusComponentBase]()
    
    func addBusComponent(bus_component: BusComponentBase) {
        bus_components.append(bus_component)
    }
    
    func deleteBusComponent(bus_component: BusComponentBase) {

    }
}

final class IoBus: BusBase {
    private var io_components: [BusComponentBase]
    
    init() {
        let dummy_component = BusComponent(base_address: 0x0000, block_size: 0x0000)
        io_components = Array(count: 0x100, repeatedValue: dummy_component)
        
        super.init(base_address: 0x0000, block_size: 0x100)
    }
    
    override func addBusComponent(bus_component: BusComponentBase) {
        super.addBusComponent(bus_component)
        io_components[Int(bus_component.getBaseAddress())] = bus_component
    }
    
    override func write(address: UInt16, value: UInt8) {
        io_components[Int(address)].write(address, value: value)
    }
    
    override func read(address: UInt16) -> UInt8 {
        return io_components[Int(address)].read(address)
    }
}

final class Bus16 : BusBase {
    private var paged_components : [BusComponentBase]
    
    init() {
        let dummy_component = BusComponent(base_address: 0x0000, block_size: 0x0000)
        paged_components = Array(count: 64, repeatedValue: dummy_component)
        
        super.init(base_address: 0x0000, block_size: 0x10000)
    }
    
    override func addBusComponent(bus_component: BusComponentBase) {
        super.addBusComponent(bus_component)

        for component in self.bus_components {
            let start = Int(component.getBaseAddress() / 1024)
            let end = start + component.getBlockSize() / 1024 - 1
            
            for i in start...end {
                paged_components[i] = component
            }
        }
    }
    
    override func write(address: UInt16, value: UInt8) {
        let index_component = Int(address) / 1024
        paged_components[index_component].write(address, value: value)
    }
    
    override func read(address: UInt16) -> UInt8 {
        let index_component = (Int(address) & 0xFFFF) / 1024
        
        return paged_components[index_component].read(address)
    }
    
    override func dumpFromAddress(fromAddress: Int, count: Int) -> [UInt8] {
        var index_component = (fromAddress & 0xFFFF) / 1024
        var address = fromAddress
        var result = [UInt8]()
        
        while result.count < count {
            result = result + paged_components[index_component].dumpFromAddress(address, count: count - result.count)
            index_component += 1
            address += result.count
        }
        
        return result
    }
}
