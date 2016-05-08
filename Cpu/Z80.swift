//
//  z80core.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

class Z80 {
    var regs : Registers
    let pins : Pins
    
    var machine_cycle = MachineCycle.OpcodeFetch // Always start in OpcodeFetch mode
    var t_cycle = 0
    var m_cycle = 0
    var control_reg : UInt8! // backup register to store parameters between t_cycles of execution
    
    var irq_kind : IrqKind?
    
    typealias OpcodeTable = [() -> Void]
    
    var opcode_tables : [OpcodeTable]!
    
    var id_opcode_table : Int
    
    init(dataBus: Bus16) {
        self.regs = Registers()
        self.pins = Pins()
        self.dataBus = dataBus
        
        id_opcode_table = table_NONE
        
        opcode_tables = [OpcodeTable](count: 5, repeatedValue: OpcodeTable(count: 0x100, repeatedValue: {}))
        
        initOpcodeTableNONE(&opcode_tables[table_NONE])
        initOpcodeTableXX(&opcode_tables[table_XX])
        initOpcodeTableXXCB(&opcode_tables[table_XXCB])
        initOpcodeTableCB(&opcode_tables[table_CB])
        initOpcodeTableED(&opcode_tables[table_ED])
        
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
    
    func addressFromPair(val_h: UInt8, _ val_l: UInt8) -> UInt16 {
        return UInt16(Int(Int(val_h) * 0x100) + Int(val_l))
    }
    
    // MARK: new emulation non exhaustive
    var dataBus : Bus16
    
    // gets next opcode from PC and executes it
    func step() {
        processInstruction()
        if t_cycle >= 4000000 {
            pins.halt = true
            return
        }
    }
    
    func processInstruction() {
        getNextOpcode()
        opcode_tables[id_opcode_table][Int(regs.ir)]()
    }
    
    func getNextOpcode() {
        t_cycle += 4
        
        // get opcode at PC into IR register
        regs.ir = dataBus.read(regs.pc)
        regs.pc += 1
        
        // save bit 7 of R to restore after increment
        let bit7 = regs.r.bit(7)
        // increment only seven bits
        regs.r.resetBit(7)
        regs.r = regs.r + 1 <= 0x7F ? regs.r + 1 : 0
        
        // restore bit 7
        regs.r.bit(7, newVal: bit7)
    }
}