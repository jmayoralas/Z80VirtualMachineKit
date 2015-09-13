//
//  z80core.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

private struct Registers {
    // Main Register Set
    // accumulator
    var a: UInt8 = 0
    var b: UInt8 = 0
    var d: UInt8 = 0
    var h: UInt8 = 0
    
    // flags
    var f: UInt8 = 0
    var c: UInt8 = 0
    var e: UInt8 = 0
    var l: UInt8 = 0
    
    // Alternate Register Set
    // accumulator
    var a_: UInt8 = 0
    var b_: UInt8 = 0
    var d_: UInt8 = 0
    var h_: UInt8 = 0
    
    // flags
    var f_: UInt8 = 0
    var c_: UInt8 = 0
    var e_: UInt8 = 0
    var l_: UInt8 = 0
    
    // Interrupt Vector
    var i: UInt8 = 0
    
    // Memory Refresh
    var r: UInt8 = 0
    
    // Index Registers
    var ix: UInt16 = 0
    var iy: UInt16 = 0
    
    // Stack Pointer
    var sp: UInt16 = 0
    
    // Program Counter
    var pc: UInt16 = 0
}

class Pins {
    var address_bus: UInt16 = 0
    var data_bus: UInt8 = 0
    var busack: Bool = false
    var busreq: Bool = false
    var halt: Bool = false
    var int: Bool = false
    var iorq: Bool = false
    var m1: Bool = false
    var mreq: Bool = false
    var nmi: Bool = false // positive edge triggered (false -> true)
    var rd: Bool = false
    var reset: Bool = false
    var rfsh: Bool = false
    var wait: Bool = false
    var wr: Bool = false
}

private enum MachineCycle: Int {
    case OpcodeFetch = 1, MemoryRead, MemoryWrite
}

private enum AddressingMode {
    case Direct, Indirect
}

class Z80 {
    let pins = Pins()
    
    private var opcodes: Array<Void -> Void>!
    private var regs = Registers()
    private var machine_cycle = MachineCycle.OpcodeFetch // Always start in OpcodeFetch mode
    private var t_cycle = 0
    private var old_busreq: Bool!
    
    private var int_request: Bool = false // interruption requested
    private var int_attended: Bool = false // interruption processed
    private var running_opcode: UInt8? // current running opcode
    private var num_params: Int = 0 // number of params in multi params opcodes
    private var params: [UInt8] = [0, 0] // array of posible params in multi params opcodes
    private var param: Int = 0 // param number in multi params opcodes decode
    private var addressing_mode = AddressingMode.Direct
    
    
    init() {
        old_busreq = pins.busreq
        opcodes = Array<Void -> Void>(count: 0x100, repeatedValue: op00)
        
        opcodes[0x00] = op00
        opcodes[0x01] = op01
        
        opcodes[0x3A] = opLd
        opcodes[0x3E] = opLd
        for n in 0x40...0x7F {
            opcodes[n] = opLdr
        }
    }
    
    func clk() {
        // waits until bus is available
        if pins.busreq || old_busreq != pins.busreq {
            old_busreq = pins.busreq
            return
        }
        pins.busack = false
        
        t_cycle++
        
        print("Cpu CLK! \(machine_cycle) - T\(t_cycle)")
        
        switch machine_cycle {
        case .OpcodeFetch:
            opcodeFetch()
            
        case .MemoryRead:
            memoryRead()
            
        case .MemoryWrite:
            memoryWrite()
        }
    }
    
    private func endMachineCycle() {
        print("address_bus: \(pins.address_bus.hexStr()) - data_bus: \(pins.data_bus.hexStr())")
        
        switch machine_cycle {
        case .OpcodeFetch:
            // data bus contains the opcode
            // Decode the opcode
            opcodes[Int(pins.data_bus)]()
            
        case .MemoryRead:
            if num_params > 0 {
                params[param - 1] = pins.data_bus
                if param < num_params {
                    // read next param
                    param++
                    pins.address_bus = regs.pc++
                    break
                } else if addressing_mode == AddressingMode.Indirect {
                    num_params = 0
                    // we have to read memory at params address
                    pins.address_bus = UInt16(Int(Int(params[1]) * 0x100) + Int(params[0]))
                    break
                }
            }
            
            
            // continue execution of current opcode
            if let opcode = running_opcode {
                opcodes[Int(opcode)]()
            }
            
        case .MemoryWrite:
            // continue execution of current opcode
            if let opcode = running_opcode {
                opcodes[Int(opcode)]()
            }
        }
        
        t_cycle = 0
        pins.busack = pins.busreq // Acknowledge bus requests
        int_request = pins.int // samples INT signal
        int_attended = false
        
        print(regs)
    }
    
    private func opcodeFetch() {
        switch t_cycle {
        case 1:
            // clear previously decoded opcode
            running_opcode = nil
            
            // program counter is placed on the address bus
            pins.address_bus = regs.pc
            
            // rd pin goes active
            pins.rd = true
            
            // we are in M1 machine cycle
            pins.m1 = true
            
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
            regs.pc++
            
            endMachineCycle()
            
        default:
            t_cycle = 0 // reset t_cycle
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
    
    
    
    // Opcodes implementation
    private func op00() { // NOP
        print("opcode 00")
    }
    
    private func op01() {
        print("opcode from \(pins.address_bus.hexStr()): \(pins.data_bus.hexStr())")
    }
    
    private func op3F() {
        print("opcode from \(pins.address_bus): \(pins.data_bus)")
    }
    
    private func opLd() {
        if let opcode = running_opcode {
            switch opcode {
            case 0x3A:
                regs.a = pins.data_bus
            case 0x3E:
                regs.a = params[1]
            default:
                break
            }
            
            // we are done with this opcode, next one please...
            machine_cycle = MachineCycle.OpcodeFetch
            
            return
        }
        
        // new opcode decoded
        running_opcode = pins.data_bus
        
        // start param counter
        param = 1
        
        switch running_opcode! {
        case 0x3A:
            addressing_mode = AddressingMode.Indirect
            num_params = 2

        case 0x3E:
            addressing_mode = AddressingMode.Direct
            num_params = 1
    
        default:
            break
        }
        
        // read parameter from PC + 1 and increment PC
        pins.address_bus = regs.pc++
        machine_cycle = MachineCycle.MemoryRead
    }
    
    private func opLdr() {
        // Are we already executing an opcode ?
        if let opcode = running_opcode {
            // if so get data from data bus and store in corresponding register
            switch opcode {
            case 0x46:
                regs.b = pins.data_bus
            case 0x4E:
                regs.c = pins.data_bus
            case 0x56:
                regs.d = pins.data_bus
            case 0x5E:
                regs.e = pins.data_bus
            case 0x66:
                regs.h = pins.data_bus
            case 0x6E:
                regs.l = pins.data_bus
            case 0x7E:
                regs.a = pins.data_bus
            default:
                break
            }
            
            // we are done with this opcode, next one please...
            machine_cycle = MachineCycle.OpcodeFetch
            
            return
        }
        // new opcode decoded
        running_opcode = pins.data_bus
        
        switch running_opcode! {
        case 0x40:
            regs.b = regs.b
        case 0x41:
            regs.b = regs.c
        case 0x42:
            regs.b = regs.d
        case 0x43:
            regs.b = regs.e
        case 0x44:
            regs.b = regs.f
        case 0x45:
            regs.b = regs.l
        case 0x47:
            regs.b = regs.a
            
        case 0x48:
            regs.c = regs.b
        case 0x49:
            regs.c = regs.c
        case 0x4A:
            regs.c = regs.d
        case 0x4B:
            regs.c = regs.e
        case 0x4C:
            regs.c = regs.f
        case 0x4D:
            regs.c = regs.l
        case 0x4F:
            regs.c = regs.a
            
        case 0x50:
            regs.d = regs.b
        case 0x51:
            regs.d = regs.c
        case 0x52:
            regs.d = regs.d
        case 0x53:
            regs.d = regs.e
        case 0x54:
            regs.d = regs.f
        case 0x55:
            regs.d = regs.l
        case 0x57:
            regs.d = regs.a
            
        case 0x58:
            regs.e = regs.b
        case 0x59:
            regs.e = regs.c
        case 0x5A:
            regs.e = regs.d
        case 0x5B:
            regs.e = regs.e
        case 0x5C:
            regs.e = regs.f
        case 0x5D:
            regs.e = regs.l
        case 0x5F:
            regs.e = regs.a
            
        case 0x60:
            regs.h = regs.b
        case 0x61:
            regs.h = regs.c
        case 0x62:
            regs.h = regs.d
        case 0x63:
            regs.h = regs.e
        case 0x64:
            regs.h = regs.f
        case 0x65:
            regs.h = regs.l
        case 0x67:
            regs.h = regs.a
            
        case 0x68:
            regs.l = regs.b
        case 0x69:
            regs.l = regs.c
        case 0x6A:
            regs.l = regs.d
        case 0x6B:
            regs.l = regs.e
        case 0x6C:
            regs.l = regs.f
        case 0x6D:
            regs.l = regs.l
        case 0x6F:
            regs.l = regs.a

        case 0x70:
            pins.data_bus = regs.b
        case 0x71:
            pins.data_bus = regs.c
        case 0x72:
            pins.data_bus = regs.d
        case 0x73:
            pins.data_bus = regs.e
        case 0x74:
            pins.data_bus = regs.f
        case 0x75:
            pins.data_bus = regs.l
        case 0x77:
            pins.data_bus = regs.a
            
        case 0x78:
            regs.a = regs.b
        case 0x79:
            regs.a = regs.c
        case 0x7A:
            regs.a = regs.d
        case 0x7B:
            regs.a = regs.e
        case 0x7C:
            regs.a = regs.f
        case 0x7D:
            regs.a = regs.l
        case 0x7F:
            regs.a = regs.a
        default:
            // test for opcodes that read from memory pointed to by HL
            let opcodes_rd_hl: [UInt8] = [0x46, 0x4E, 0x56, 0x5E, 0x66, 0x6E, 0x7E]
            if opcodes_rd_hl.contains(running_opcode!) {
                pins.address_bus = UInt16(Int(Int(regs.h) * 0x100) + Int(regs.l))
                machine_cycle = MachineCycle.MemoryRead
                
                return
            }
        }
        
        // test for opcodes that write to memory pointed to by HL
        let opcodes_wr_hl: [UInt8] = [0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77]
        if opcodes_wr_hl.contains(running_opcode!) {
            pins.address_bus = UInt16(Int(Int(regs.h) * 0x100) + Int(regs.l))
            machine_cycle = MachineCycle.MemoryWrite
            
            return
        }
    }
}