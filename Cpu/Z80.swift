//
//  z80core.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

final class Z80 {
    private var regs : Registers
    let pins : Pins
    let cu : ControlUnit
    
    var program_end: Bool = false
    
    private var opcodes: Array<Void -> Void>!
    
    private var machine_cycle = MachineCycle.OpcodeFetch // Always start in OpcodeFetch mode
    private var t_cycle = 0
    private var m_cycle = 0
    private var old_busreq: Bool!
    
    private var prefix: UInt8?
    
    init(dataBus: Bus16) {
        self.regs = Registers()
        self.pins = Pins()
        self.dataBus = dataBus
        
        self.cu = ControlUnit(dataBus: dataBus, pins: pins)
        
        self.old_busreq = pins.busreq
        
        reset()
    }
    
    func reset() {
        regs.pc = 0x0000
        regs.int_mode = 0
        regs.IFF1 = false
        regs.IFF2 = false
        regs.i = 0x00
        regs.r = 0x00
        regs.sp = 0x7FFF

        pins.data_bus = 0x00
        pins.address_bus = 0x00
        pins.busack = false
        pins.busreq = false
        pins.halt = false
        pins.int = false
        pins.iorq = false
        pins.m1 = false
        pins.mreq = false
        pins.nmi = false
        pins.rd = false
        pins.reset = false
        pins.rfsh = false
        pins.wait = false
        pins.wr = false
        
        t_cycle = 0
        m_cycle = 0
        
        machine_cycle = .OpcodeFetch
        old_busreq = pins.busreq
    }
    
    func org(pc: UInt16) {
        regs.pc = pc
    }
    
    func getRegs() -> Registers {
        return regs
    }
    
    func getTCycle() -> Int {
        return t_cycle
    }
    
    // MARK: new emulation non exhaustive
    var dataBus : Bus16
    
    // gets next opcode from PC and executes it
    func step() {
        cu.processInstruction(regs: &regs, t_cycle: &t_cycle)
        if t_cycle >= 4000000 {
            pins.halt = true
            return
        }
    }
}