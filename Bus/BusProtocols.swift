//
//  BusProtocols.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 17/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

protocol BusComponent {
    var base_address: Int { get set }
    var block_size: Int { get set }
    
    func getBaseAddress() -> Int
    func getBlockSize() -> Int
    func read(address: Int) -> UInt8
    mutating func write(address: Int, value: UInt8)
    func dumpFromAddress(fromAddress: Int, count: Int) -> [UInt8]
}

extension BusComponent {
    func getBaseAddress() -> Int { return self.base_address }
    func getBlockSize() -> Int { return self.block_size }
    func read(address: Int) -> UInt8 { return 0xFF }
    mutating func write(address: Int, value: UInt8) { }
    func dumpFromAddress(fromAddress: Int, count: Int) -> [UInt8] {
        return Array(count: count, repeatedValue: UInt8(0xFF))
    }
}

/////////////////////////////////////////////////////////////////////////////

protocol DataStore: BusComponent {
    var buffer: [UInt8] { get set }
    var delegate : MemoryChange? { get set }
}

extension DataStore {
    func read(address: Int) -> UInt8 {
        let local_address = address - getBaseAddress()
        return 0 <= local_address && local_address < buffer.count ? buffer[local_address] : 0xFF
    }
    
    mutating func write(address: Int, value: UInt8) {
        let local_address = address - getBaseAddress()
        if 0 <= local_address && local_address < buffer.count {
            buffer[local_address] = value
            delegate?.MemoryWriteAtAddress?(Int(address), byte: value)
        }
    }
    
    func dumpFromAddress(fromAddress: Int, count: Int) -> [UInt8] {
        let topAddress = Int(self.base_address) + self.block_size - 1
        
        let myFromAddress = (fromAddress < 0 ? 0 : fromAddress) - Int(self.base_address)
        var myToAddress = fromAddress + (count > buffer.count ? buffer.count : count) - 1 - Int(self.base_address)
        myToAddress = myToAddress > topAddress ? topAddress : myToAddress
        
        return Array(buffer[myFromAddress...myToAddress])
    }
}

////////////////////////////////////////////////////////////////////////////

protocol BusComponentCollection {
    var bus_components: [BusComponent] { get set }
    
    mutating func addBusComponent(bus_component: BusComponent)
    mutating func onUpdate()
}

extension BusComponentCollection {
    mutating func addBusComponent(bus_component: BusComponent) {
        bus_components.append(bus_component)
        onUpdate()
    }
}

////////////////////////////////////////////////////////////////////////////

struct  DummyBusComponent: BusComponent {
    var base_address: Int = 0
    var block_size: Int = 0
}


protocol Bus: BusComponent, BusComponentCollection {
    var paged_components: [BusComponent] { get set }
}

extension Bus {
    mutating func onUpdate() {
        for component in bus_components {
            let start = component.getBaseAddress() / 1024
            let end = start + component.getBlockSize() / 1024 - 1
            
            for i in start...end {
                paged_components[i] = component
            }
        }
    }
    
    mutating func write(address: UInt16, value: UInt8) {
        paged_components[Int(address) / 1024].write(Int(address), value: value)
    }
    
    func read(address: UInt16) -> UInt8 {
        return paged_components[Int(address) / 1024].read(Int(address))
    }
    
    func dumpFromAddress(fromAddress: Int, count: Int) -> [UInt8] {
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

struct GenericBus: Bus {
    var base_address: Int = 0
    var block_size: Int = 0
    var bus_components = [BusComponent]()
    var paged_components = [BusComponent]()
    
    init(bit_size: Int) {
        self.base_address = 0x0000
        self.block_size = 2 << (bit_size - 1)
        let dummy_component = DummyBusComponent()
        self.paged_components = Array<BusComponent>(count: (self.block_size) / 1024, repeatedValue: dummy_component)
    }
}

struct RamComponent: DataStore {
    var base_address: Int
    var block_size: Int
    var buffer: [UInt8]
    var delegate : MemoryChange?
    
    init(base_address: Int, size: Int) {
        self.base_address = base_address
        self.block_size = size
        self.buffer = [UInt8](count: size, repeatedValue: 0x00)
    }
}
