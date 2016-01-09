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

@objc public class Z80VirtualMachineKit: NSObject, MemoryChange
{
    public var delegate: Z80VirtualMachineStatus?
    
    private let memory : Memory
    private let cpu : Z80
    private var io_devices : [IODevice]
    
    override public init() {
        cpu = Z80()
        memory = Memory(pins: cpu.pins)
        io_devices = []
        super.init()
        
        memory.delegate = self
    }
    
    public func reset() {
        cpu.reset()
    }
    
    public func run() {
        // var instructions = 0
        repeat {
            step()
            // instructions++
        } while !cpu.pins.halt // && instructions <= 6200
    }
    
    public func step() {
        repeat {
            clk()
        } while (cpu.getMCycle() > 1 || cpu.getTCycle() > 1) && !cpu.pins.halt
    }
    
    public func clk() {
        cpu.clk()
        if cpu.pins.mreq {
            memory.clk() // memory's clock line is connected to mreq pin of cpu
        }
        
        for io_device in io_devices {
            io_device.clk()
        }
    }
    
    public func addIoDevice(io_device: IODevice) {
        io_devices.append(io_device)
    }
    
    public func loadRamAtAddress(address: Int, data: [UInt8]) {
        memory.poke(address, bytes: data)
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
    
    public func getMCycle() -> Int {
        return cpu.getMCycle()
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
        return memory.dumpFromAddress(fromAddress, toAddress: toAddress)
    }
    
    func MemoryWriteAtAddress(address: Int, byte: UInt8) {
        delegate?.Z80VMMemoryWriteAtAddress?(address, byte: byte)
    }
    
    func MemoryReadAtAddress(address: Int, byte: UInt8) {
        delegate?.Z80VMMemoryReadAtAddress?(address, byte: byte)
    }
}