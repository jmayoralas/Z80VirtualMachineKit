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
}

@objc final public class Z80VirtualMachineKit: NSObject, BusComponentWatcher
{
    public var delegate: Z80VirtualMachineStatus?
    
    private let cpu : Z80
    private var instructions: Int
    
    private var old_m1: Bool
    
    override public init() {
        cpu = Z80(dataBus: Bus16(), ioBus: IoBus())
        
        old_m1 = cpu.pins.m1
        instructions = -1
        
        super.init()
        
        // connect the 16k ROM
        var rom = Rom(base_address: 0x0000, block_size: 0x4000)
        rom.delegate = self
        cpu.dataBus.addBusComponent(rom)
        
        // add the upper 32k to emulate a 48k Spectrum
        var ram = Ram(base_address: 0x8000, block_size: 0x8000)
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
    }
    
    public func loadRamAtAddress(address: Int, data: [UInt8]) {
        for i in 0..<data.count {
            cpu.dataBus.write(address + i, value: data[i])
        }
    }
    
    public func loadRomAtAddress(address: Int, data: [UInt8]) throws {
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
    
    public func getAddressBus() -> Int {
        return cpu.pins.address_bus
    }
    
    public func setPc(pc: Int) {
        cpu.org(pc)
    }
    
    public func clearMemory() {
    }
    
    public func dumpMemoryFromAddress(fromAddress: Int, toAddress: Int) -> [UInt8] {
        return cpu.dataBus.dump(fromAddress, count: toAddress - fromAddress + 1)
    }
    
    func onWrite(address: Int, value: UInt8) {
        delegate?.Z80VMMemoryWriteAtAddress?(address, byte: value)
    }
}