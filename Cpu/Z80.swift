//
//  z80core.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

class Z80 {
    private var regs : Registers
    let pins : Pins
    let cu : ControlUnit
    
    var program_end: Bool = false
    
    private var opcodes: Array<Void -> Void>!
    
    private var machine_cycle = MachineCycle.OpcodeFetch // Always start in OpcodeFetch mode
    private var t_cycle = 0
    private var T = 0
    private var m_cycle = 0
    private var old_busreq: Bool!
    
    private var prefix: UInt8?
    
    init() {
        regs = Registers()
        pins = Pins()
        cu = ControlUnit(pins: pins)
        
        old_busreq = pins.busreq
        
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
        T = 0
        machine_cycle = .OpcodeFetch
        old_busreq = pins.busreq
    }
    
    func org(pc: UInt16) {
        regs.pc = pc
    }
    
    func clk() {
        // waits while wait signal is active
        if pins.iorq && pins.wait {
            return
        }
        
        // waits until bus is available
        if pins.busreq || old_busreq != pins.busreq {
            old_busreq = pins.busreq
            return
        }
        
        pins.busack = false
        
        t_cycle += 1
        T += 1
        
        if T == 240000000 {
            pins.halt = true
            return
        }
        
        switch machine_cycle {
        case .SoftIrq:
            softIrq()
        
        case .NMIrq:
            fallthrough
            
        case .OpcodeFetch:
            opcodeFetch()
            
        case .MemoryRead:
            memoryRead()
            
        case .MemoryWrite:
            memoryWrite()
            
        case .IoRead:
            ioRead()
            
        case .IoWrite:
            ioWrite()
            
        case .UlaOperation:
            endMachineCycle()
            
        case .TimeWait:
            endMachineCycle()
        }
    }
    
    func getRegs() -> Registers {
        return regs
    }
    
    func getTCycle() -> Int {
        return t_cycle
    }
    
    func getMCycle() -> Int {
        return m_cycle
    }
    
    func getTCount() -> Int {
        return T
    }

    private func endMachineCycle() {
        /*
        print("address_bus: \(pins.address_bus.hexStr()) - data_bus: \(pins.data_bus.hexStr()) \(pins.data_bus.binStr) - PC: \(regs.pc.hexStr()) - M: \(m_cycle) - T: \(t_cycle) - \(machine_cycle)")
        print(" IR: \(regs.ir.hexStr())                      CNPxHxZS")
        print("  A: \(regs.a.hexStr()) \(regs.a.binStr) -   F: \(regs.f.hexStr()) \(regs.f.binStr) - SP: \(regs.sp.hexStr())")
        print("  B: \(regs.b.hexStr()) \(regs.b.binStr) -   C: \(regs.c.hexStr()) \(regs.c.binStr) -  I: \(regs.i.hexStr())")
        print("  D: \(regs.d.hexStr()) \(regs.d.binStr) -   E: \(regs.e.hexStr()) \(regs.e.binStr)")
        print("  H: \(regs.h.hexStr()) \(regs.h.binStr) -   L: \(regs.l.hexStr()) \(regs.l.binStr)")
        print("IXH: \(regs.ixh.hexStr()) \(regs.ixh.binStr) - IXL: \(regs.ixl.hexStr()) \(regs.ixl.binStr)")
        print("IYH: \(regs.iyh.hexStr()) \(regs.iyh.binStr) - IYL: \(regs.iyl.hexStr()) \(regs.iyl.binStr)")
        */
        cu.processOpcode(&regs, t_cycle, m_cycle, &machine_cycle)
        
        if machine_cycle != .TimeWait {
            t_cycle = 0
            m_cycle += 1
        }
        
        // samples busreq, int and nmi signals on last T state
        if !cu.isPrefixed() && machine_cycle == .OpcodeFetch {
            pins.busack = pins.busreq // Acknowledge bus requests
            // samples INT signal
            if (pins.int && regs.IFF1) || pins.nmi {
                if pins.nmi {
                    machine_cycle = .NMIrq
                    regs.IFF2 = regs.IFF1
                    regs.IFF1 = false
                } else {
                    // one instruction delay after EI to ack the interrupt
                    if regs.ir != 0xFB {
                        machine_cycle = .SoftIrq
                        regs.IFF2 = false
                        regs.IFF1 = false
                    }
                }
            }
        }
    }

    private func opcodeFetch() {
        switch t_cycle {
        case 1:
            // program counter is placed on the address bus
            pins.address_bus = regs.pc
            
            // rd pin goes active
            pins.rd = true
            
            // we are in M1 machine cycle
            pins.m1 = true
            // but if a prefixed opcode is running don't reset m_cycle counter
            if !cu.isPrefixed() {
                m_cycle = 1
            }
            
        case 2:
            // mreq goes active to wake up the memory
            pins.mreq = true
            
        case 3:
            // turn off mreq, m1 and rd signals
            pins.mreq = false
            pins.rd = false
            pins.m1 = false
            
            // refresh cycle
            pins.rfsh = true
            
        case 4:
            pins.rfsh = false
            
            // program counter update
            regs.pc += 1
            
            // save bit 7 of R to restore after increment
            let bit7 = regs.r.bit(7)
            // increment only seven bits
            regs.r.resetBit(7)
            regs.r = regs.r + 1 <= 0x7F ? regs.r + 1 : 0
            
            // restore bit 7
            regs.r.bit(7, newVal: bit7)
            
            // backup data bus into instruction register
            regs.ir = pins.data_bus
            
            endMachineCycle()
            
        default:
            t_cycle = 0 // reset t_cycle
        }
    }

    private func softIrq() {
        switch t_cycle {
        case 1:
            // program counter is placed on the address bus
            pins.address_bus = regs.pc
            
            // we are in M1 machine cycle
            pins.m1 = true
            m_cycle = 1
            
        case 3:
            pins.iorq = true
            
        case 5:
            // turn off mreq, m1 and rd signals
            pins.iorq = false
            pins.m1 = false
            
            // refresh cycle
            pins.rfsh = true
            
        case 6:
            pins.rfsh = false
            
            // backup data bus into instruction register
            regs.ir = pins.data_bus
            
            endMachineCycle()
            
        default:
            if t_cycle > 5 {
                t_cycle = 0 // reset t_cycle
            }
        }
    }

    private func memoryRead() {
        switch t_cycle {
        case 1:
            // memory address should be previously placed on the address bus (i.e.: by the last decoded instruction)
            // rd pin goes active
            pins.rd = true
            
        case 2:
            // mreq goes active to wake up the memory
            pins.mreq = true
            
        case 3:
            // turn off mreq and rd signals
            pins.mreq = false
            pins.rd = false
            endMachineCycle()
            
        default:
            t_cycle = 0
        }
    }
    
    private func memoryWrite() {
        switch t_cycle {
        case 1:
            // memory address should be previously placed on the address bus (i.e.: by the last decoded instruction)
            // data bus should contain the byte to write
            break
            
        case 2:
            // wr pin goes active
            pins.wr = true
            
            // mreq goes active to wake up the memory
            pins.mreq = true
            
        case 3:
            // turn off mreq and wr signals
            pins.mreq = false
            pins.wr = false
            endMachineCycle()
            
        default:
            t_cycle = 0
        }
    }
    
    private func ioRead() {
        switch t_cycle {
        case 1:
            // port address should be previously placed on the address bus (i.e.: by the last decoded instruction)
            break
            
        case 2:
            // rd pin goes active
            pins.rd = true
            
            // iorq goes active to wake up the memory
            pins.iorq = true
            
        case 3: //(WAIT)
            break
            
        case 4:
            // turn off iorq and rd signals
            pins.iorq = false
            pins.rd = false
            endMachineCycle()
            
        default:
            t_cycle = 0
        }
    }
    
    private func ioWrite() {
        switch t_cycle {
        case 1:
            // memory address should be previously placed on the address bus (i.e.: by the last decoded instruction)
            // data bus should contain the byte to write
            break
            
        case 2:
            // wr pin goes active
            pins.wr = true
            
            // mreq goes active to wake up the memory
            pins.iorq = true
            
        case 3: // WAIT
            break
            
        case 4:
            // turn off iorq and wr signals
            pins.iorq = false
            pins.wr = false
            endMachineCycle()
            
        default:
            t_cycle = 0
        }
    }
}