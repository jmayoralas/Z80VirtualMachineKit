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

// memory.poke(0x0000, bytes: [0x06, 0x11, 0x0E, 0x77, 0x3E, 0xFF, 0x02, 0xDD, 0x2A, 0x77, 0x11, 0x76])
// memory.poke(0x0000, bytes: [0x26, 0x11, 0x2E, 0x77, 0x46, 0x76])
memory.poke(0x0000, bytes: [0xDD, 0xCB, 0x01, 0x00, 0x76])
memory.poke(0x1177, bytes: [0xFE])
memory.poke(0x1178, bytes: [0xFF])

while !cpu.program_end {
    try cpu.clk()
    if cpu.pins.mreq { memory.clk() } // memory's clock line is connected to mreq pin of cpu

}
