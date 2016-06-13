//
//  z80core.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

protocol Z80Delegate {
    func frameCompleted()
}

class Z80 {
    private let TICS_PER_FRAME = 69888
    
    typealias OpcodeTable = [() -> Void]
    
    var regs : Registers
    
    var t_cycle = 0
    var halted: Bool = false;
    
    var irq_kind : IrqKind?
    
    var opcode_tables : [OpcodeTable]!
    
    var id_opcode_table : Int
    
    var frameTics: Int = 0;
    
    let dataBus : Bus16
    let ioBus : IoBus
    
    var delegate: Z80Delegate?
    
    init(dataBus: Bus16, ioBus: IoBus) {
        self.regs = Registers()
        self.dataBus = dataBus
        self.ioBus = ioBus
        
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
        
        regs.sp = 0xFFFF
        
        regs.af = 0xFFFF
        regs.bc = 0xFFFF
        regs.de = 0xFFFF
        regs.hl = 0xFFFF
        regs.ix = 0xFFFF
        regs.iy = 0xFFFF
        
        regs.af_ = 0xFFFF
        regs.bc_ = 0xFFFF
        regs.de_ = 0xFFFF
        regs.hl_ = 0xFFFF
        
        t_cycle = 0
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
    
    // gets next opcode from PC and executes it
    func step() {
        let old_t_cycle = t_cycle
        
        repeat {
            processInstruction()
        } while id_opcode_table != table_NONE
        
        frameTics += t_cycle - old_t_cycle
        if frameTics >= TICS_PER_FRAME {
            delegate?.frameCompleted()
            frameTics -= TICS_PER_FRAME
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
        regs.pc = regs.pc &+ 1
        
        if regs.ir != 0xCB || id_opcode_table == table_NONE {
            // save bit 7 of R to restore after increment
            let bit7 = regs.r.bit(7)
            // increment only seven bits
            regs.r.resetBit(7)
            regs.r = regs.r + 1 <= 0x7F ? regs.r + 1 : 0
            
            // restore bit 7
            regs.r.bit(7, newVal: bit7)
        }
    }
}