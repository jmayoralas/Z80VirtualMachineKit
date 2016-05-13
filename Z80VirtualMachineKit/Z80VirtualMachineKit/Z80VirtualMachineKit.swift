//
//  VirtualMachine.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 31/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

@objc public protocol Z80VirtualMachineStatus {
    optional func Z80VMMemoryWriteAtAddress(address: Int, byte: UInt8)
    optional func Z80VMMemoryReadAtAddress(address: Int, byte: UInt8)
}

@objc final public class Z80VirtualMachineKit: NSObject, MemoryChange
{
    public var delegate: Z80VirtualMachineStatus?
    
    private let memory : Memory
    private let cpu : Z80
    private var io_devices : [IODevice]
    private var instructions: Int
    
    private var old_m1: Bool
    
    override public init() {
        cpu = Z80(dataBus: Bus16(), ioBus: Bus16())
        old_m1 = cpu.pins.m1
        memory = Memory(pins: cpu.pins)
        io_devices = []
        instructions = -1
        
        super.init()
        
        memory.delegate = self
        
        let ram = Ram(base_address: 0x0000, block_size: 0x10000)
        ram.delegate = self
        cpu.dataBus.addBusComponent(ram)
    }
    
    public func reset() {
        cpu.reset()
        instructions = -1
    }
    
    public func run() {
        repeat {
            step()
        } while !cpu.pins.halt // && instructions <= 6200
    }
    
    public func step() {
        instructions += 1
        cpu.step()
    }
    
    public func getInstructionsCount() -> Int {
        return instructions < 0 ? 0 : instructions
    }
    
    public func addIoDevice(port: UInt8) {
        io_devices.append(IODevice(pins: cpu.pins, port: port))
    }
    
    public func loadRamAtAddress(address: Int, data: [UInt8]) {
        for i in 0..<data.count {
            cpu.dataBus.write(UInt16(address + i), value: data[address + i])
        }
        // cpu.dataBus.write(0x000c, value: 0xC3)
    }
    
    public func loadRomAtAddress(address: Int, data: [UInt8]) throws {
        try memory.loadRomAtAddress(address, data: data)
    }
    
    public func getCpuRegs() -> Registers {
        return cpu.getRegs()
    }
    
    public func getTCycle() -> Int {
        return cpu.getTCycle()
    }
    
    public func getDataBus() -> UInt8 {
        return cpu.pins.data_bus
    }
    
    public func getAddressBus() -> UInt16 {
        return cpu.pins.address_bus
    }
    
    public func setPc(pc: UInt16) {
        cpu.org(pc)
    }
    
    public func clearMemory() {
        memory.clear()
    }
    
    public func dumpMemoryFromAddress(fromAddress: Int, toAddress: Int) -> [UInt8] {
        return cpu.dataBus.dumpFromAddress(fromAddress, count: toAddress - fromAddress + 1)
    }
    
    func MemoryWriteAtAddress(address: Int, byte: UInt8) {
        delegate?.Z80VMMemoryWriteAtAddress?(address, byte: byte)
    }
    
    func MemoryReadAtAddress(address: Int, byte: UInt8) {
        delegate?.Z80VMMemoryReadAtAddress?(address, byte: byte)
    }
}