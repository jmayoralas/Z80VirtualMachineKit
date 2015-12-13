//
//  main.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 8/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

var a = MachineCycle.TimeWait

let cpu = Z80()
let memory = Memory(pins: cpu.pins)
let io_dev_1 = IODevice(pins: cpu.pins, port: 0x01)
let io_dev_2 = TestDevice(pins: cpu.pins, port: 0x02)

// memory.poke(0x0000, bytes: [0x06, 0x11, 0x0E, 0x77, 0x3E, 0xFF, 0x02, 0xDD, 0x2A, 0x77, 0x11, 0x76])
memory.poke(0x0000, bytes: [0x3E, 0x7F, 0xC9])
memory.poke(0x1000, bytes: [0x31, 0xFF, 0x7F, 0x21, 0x77, 0x11, 0xE5, 0x21, 0x44, 0x22, 0xE3, 0x76])
memory.poke(0x1177, bytes: [0x3E, 0x65, 0xC0, 0x76])

    while !cpu.program_end {
    cpu.clk()
    if cpu.pins.mreq {
        memory.clk() // memory's clock line is connected to mreq pin of cpu
    }
    io_dev_1.clk()
    io_dev_2.clk()
}
