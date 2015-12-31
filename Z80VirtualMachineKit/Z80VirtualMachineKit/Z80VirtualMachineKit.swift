//
//  VirtualMachine.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 31/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

public class Z80VirtualMachineKit
{
    private let memory : Memory
    private let cpu : Z80
    private var io_devices : [IODevice]
    
    public init() {
        cpu = Z80()
        memory = Memory(pins: cpu.pins)
        io_devices = []
    }
    
    public func step() {
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
}