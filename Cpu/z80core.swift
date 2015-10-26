//
//  z80core.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

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
    var ixh: UInt8 = 0
    var ixl: UInt8 = 0
    var iyh: UInt8 = 0
    var iyl: UInt8 = 0
    
    // Stack Pointer
    var sp: UInt16 = 0
    
    // Program Counter
    var pc: UInt16 = 0
}

private enum MachineCycle: Int {
    case OpcodeFetch = 1, MemoryRead, MemoryWrite, UlaOperation
}

private enum UlaOp {
    case Add, Sub, And, Or, Xor
}

class Z80 {
    let pins = Pins()
    var program_end: Bool = false
    
    private var opcodes: Array<Void -> Void>!
    private var regs = Registers()
    private var machine_cycle = MachineCycle.OpcodeFetch // Always start in OpcodeFetch mode
    private var t_cycle = 0
    private var m_cycle = 0
    private var old_busreq: Bool!
    
    private var int_request: Bool = false // interruption requested
    private var int_attended: Bool = false // interruption processed
    private var running_opcode: UInt8? // current running opcode
    
    private var buffer: [UInt8]?
    private var num_bytes = 0
    
    private var prefix: UInt8?
    
    init() {
        old_busreq = pins.busreq
        opcodes = Array<Void -> Void>(count: 0x100, repeatedValue: op00)
        
        for n in 0x40...0x7F {
            opcodes[n] = opLd
        }
        opcodes[0x00] = op00
        
        opcodes[0x01] = opLd
        opcodes[0x02] = opLd
        opcodes[0x03] = opIncDec
        opcodes[0x04] = opIncDec
        opcodes[0x05] = opIncDec
        opcodes[0x06] = opLd
        opcodes[0x0A] = opLd
        opcodes[0x0B] = opIncDec
        opcodes[0x0C] = opIncDec
        opcodes[0x0D] = opIncDec
        opcodes[0x0E] = opLd
        opcodes[0x11] = opLd
        opcodes[0x12] = opLd
        opcodes[0x13] = opIncDec
        opcodes[0x14] = opIncDec
        opcodes[0x15] = opIncDec
        opcodes[0x16] = opLd
        opcodes[0x1A] = opLd
        opcodes[0x1B] = opIncDec
        opcodes[0x1C] = opIncDec
        opcodes[0x1D] = opIncDec
        opcodes[0x1E] = opLd
        opcodes[0x21] = opLd
        opcodes[0x22] = opLd
        opcodes[0x23] = opIncDec
        opcodes[0x24] = opIncDec
        opcodes[0x25] = opIncDec
        opcodes[0x26] = opLd
        opcodes[0x2A] = opLd
        opcodes[0x2B] = opIncDec
        opcodes[0x2C] = opIncDec
        opcodes[0x2D] = opIncDec
        opcodes[0x2E] = opLd
        opcodes[0x31] = opLd
        opcodes[0x32] = opLd
        opcodes[0x33] = opIncDec
        opcodes[0x34] = opIncDec
        opcodes[0x36] = opLd
        opcodes[0x3A] = opLd
        opcodes[0x3B] = opIncDec
        opcodes[0x3E] = opLd
        opcodes[0xDD] = opPrefix
        opcodes[0xED] = opPrefix
        opcodes[0xFD] = opPrefix
        opcodes[0xF9] = opLd
        
        opcodes[0x76] = op76
        
    }
    
    func clk() {
        // program ended ?
        if program_end { return }
        
        // waits until bus is available
        if pins.busreq || old_busreq != pins.busreq {
            old_busreq = pins.busreq
            return
        }
        pins.busack = false
        
        t_cycle++
        
        print("Cpu CLK! \(machine_cycle) - M\(m_cycle) - T\(t_cycle)")
        
        switch machine_cycle {
        case .OpcodeFetch:
            opcodeFetch()
            
        case .MemoryRead:
            memoryRead()
            
        case .MemoryWrite:
            memoryWrite()
            
        case .UlaOperation:
            endMachineCycle()
        }
    }

    private func endMachineCycle() {
        print("address_bus: \(pins.address_bus.hexStr()) - data_bus: \(pins.data_bus.hexStr()) - flags: \(regs.f.binArray)")
        
        switch machine_cycle {
        case .OpcodeFetch:
            // data bus contains the opcode
            // Decode the opcode
            opcodes[Int(pins.data_bus)]()
            
        case .MemoryRead:
            buffer!.append(pins.data_bus)
            num_bytes--
            if num_bytes > 0 {
                pins.address_bus++
                break
            }
            
            // continue execution of current opcode
            if let opcode = running_opcode {
                opcodes[Int(opcode)]()
            }
        case .MemoryWrite:
            if buffer!.count > 0 {
                pins.data_bus = buffer![0]
                buffer!.removeFirst()
                pins.address_bus++
                break
            }
            
            // continue execution of current opcode
            if let opcode = running_opcode {
                opcodes[Int(opcode)]()
            }
        case .UlaOperation:
            // continue execution of current opcode
            if let opcode = running_opcode {
                opcodes[Int(opcode)]()
            }
        }
        
        if machine_cycle != .UlaOperation {
            t_cycle = 0
            m_cycle++
            pins.busack = pins.busreq // Acknowledge bus requests
            int_request = pins.int // samples INT signal
            int_attended = false
        }
        
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
            if prefix == nil {
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
    
    private func writeToMemoryIX(byte: UInt8) {
        pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
        pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
        pins.data_bus = byte
        buffer = []
        machine_cycle = MachineCycle.MemoryWrite
    }

    private func writeToMemoryIY(byte: UInt8) {
        pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
        pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
        pins.data_bus = byte
        buffer = []
        machine_cycle = MachineCycle.MemoryWrite
    }

    private func addressFromPair(val_h: UInt8, _ val_l: UInt8) -> UInt16 {
        return UInt16(Int(Int(val_h) * 0x100) + Int(val_l))
    }
    
    private func pairFromAddress(address: UInt16) -> (h: UInt8, l: UInt8) {
        return (UInt8(address / 0x100), UInt8(address % 0x100))
    }
    
    // Opcodes implementation
    private func op00() { // NOP
        print("NOP")
    }
    
    private func op76() {
        print("HALT !!")
        program_end = true
    }
    
    private func op3F() {
        print("opcode from \(pins.address_bus): \(pins.data_bus)")
    }
    
    private func opPrefix() {
        prefix = pins.data_bus
    }
    
    private func opLd() {
        // fix the m_cycle if we are executing prefixed opcodes
        var my_m_cycle = m_cycle
        if prefix != nil {
            my_m_cycle--
        }
        
        // Are we already executing an opcode ?
        if let opcode = running_opcode {
            // if so get data from data bus and store in corresponding register
            switch opcode {
            case 0x01:
                regs.b = buffer![1]
                regs.c = buffer![0]
            case 0x06:
                regs.b = buffer![0]
            case 0x0A:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    num_bytes = 1
                    buffer = []
                    return
                }
                regs.a = pins.data_bus
            case 0x0E:
                regs.c = buffer![0]
            case 0x11:
                regs.d = buffer![1]
                regs.e = buffer![0]
            case 0x16:
                regs.d = buffer![0]
            case 0x1A:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    num_bytes = 1
                    buffer = []
                    return
                }
                regs.a = pins.data_bus
            case 0x1E:
                regs.e = buffer![0]
            case 0x21:
                if let pr = prefix {
                    switch pr {
                    case 0xDD:
                        regs.ixh = buffer![1]
                        regs.ixl = buffer![0]
                    case 0xFD:
                        regs.iyh = buffer![1]
                        regs.iyl = buffer![0]
                    default:
                        break
                    }
                    
                    prefix = nil
                } else {
                    regs.h = buffer![1]
                    regs.l = buffer![0]
                }
            case 0x22:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    machine_cycle = MachineCycle.MemoryWrite
                    if let pr = prefix {
                        switch pr {
                        case 0xDD:
                            pins.data_bus = regs.ixl
                            buffer = [regs.ixh]
                        case 0xFD:
                            pins.data_bus = regs.iyl
                            buffer = [regs.iyh]
                        default:
                            break
                        }
                        
                        prefix = nil
                    } else {
                        pins.data_bus = regs.l
                        buffer = [regs.h]
                    }
                    
                    return
                }
            case 0x26:
                if let pr = prefix {
                    switch pr {
                    case 0xDD:
                        regs.ixh = buffer![0]
                    case 0xFD:
                        regs.iyh = buffer![0]
                    default:
                        break
                    }
                    prefix = nil
                } else {
                    regs.h = buffer![0]
                }
            case 0x2A:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    num_bytes = 2
                    buffer = []
                    return
                }
                
                if let pr = prefix {
                    switch pr {
                    case 0xDD:
                        regs.ixl = buffer![0]
                        regs.ixh = buffer![1]
                    case 0xFD:
                        regs.iyl = buffer![0]
                        regs.iyh = buffer![1]
                    default:
                        break
                    }
                    prefix = nil
                } else {
                    regs.l = buffer![0]
                    regs.h = buffer![1]
                }
            case 0x2E:
                if let pr = prefix {
                    switch pr {
                    case 0xDD:
                        regs.ixl = buffer![0]
                    case 0xFD:
                        regs.iyl = buffer![0]
                    default:
                        break
                    }
                    prefix = nil
                } else {
                    regs.l = buffer![0]
                }
            case 0x31:
                regs.sp = addressFromPair(buffer![1], buffer![0])
            case 0x32:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    pins.data_bus = regs.a
                    buffer = []
                    machine_cycle = MachineCycle.MemoryWrite
                    
                    return
                }
            case 0x36:
                if let pr = prefix {
                    if my_m_cycle == 3 {
                        switch pr {
                        case 0xDD:
                            writeToMemoryIX(buffer![1])
                            
                            return
                        case 0xFD:
                            writeToMemoryIY(buffer![1])
                            
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                } else {
                    if my_m_cycle == 2 {
                        pins.address_bus = addressFromPair(regs.h, regs.l)
                        pins.data_bus = buffer![0]
                        buffer = []
                        machine_cycle = MachineCycle.MemoryWrite
                        
                        return
                    }
                }
            case 0x3A:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    num_bytes = 1
                    buffer = []
                    return
                }
                regs.a = pins.data_bus
            case 0x3E:
                regs.a = buffer![0]
            case 0x43:
                if let pr = prefix {
                    switch pr {
                    case 0xED:
                        pins.address_bus = addressFromPair(buffer![1], buffer![0])
                        machine_cycle = .MemoryWrite
                        pins.data_bus = regs.c
                        buffer = [regs.b]
                        
                    default:
                        break
                    }
                    prefix = nil
                    
                    return
                }
            case 0x46:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            return
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                }
                regs.b = pins.data_bus
            case 0x4B:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    num_bytes = 2
                    buffer = []
                    return
                }
                
                if let pr = prefix {
                    if pr == 0xED {
                        regs.c = buffer![0]
                        regs.b = buffer![1]
                    }
                    prefix = nil
                }
            case 0x4E:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                    
                }
                regs.c = pins.data_bus
            case 0x53:
                if let pr = prefix {
                    switch pr {
                    case 0xED:
                        pins.address_bus = addressFromPair(buffer![1], buffer![0])
                        machine_cycle = .MemoryWrite
                        pins.data_bus = regs.e
                        buffer = [regs.d]
                        
                    default:
                        break
                    }
                    prefix = nil
                    
                    return
                }
            case 0x56:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                    
                }
                regs.d = pins.data_bus
            case 0x5B:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    num_bytes = 2
                    buffer = []
                    return
                }
                
                if let pr = prefix {
                    if pr == 0xED {
                        regs.e = buffer![0]
                        regs.d = buffer![1]
                    }
                    prefix = nil
                }
            case 0x5E:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        default:
                            break
                        }
                    }
                    prefix = nil
                    
                }
                regs.e = pins.data_bus
            case 0x63:
                if let pr = prefix {
                    switch pr {
                    case 0xED:
                        pins.address_bus = addressFromPair(buffer![1], buffer![0])
                        machine_cycle = .MemoryWrite
                        pins.data_bus = regs.l
                        buffer = [regs.h]
                        
                    default:
                        break
                    }
                    prefix = nil
                    
                    return
                }

            case 0x66:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                    
                }
                regs.h = pins.data_bus
            case 0x6B:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    num_bytes = 2
                    buffer = []
                    return
                }
                
                if let pr = prefix {
                    if pr == 0xED {
                        regs.l = buffer![0]
                        regs.h = buffer![1]
                    }
                    prefix = nil
                }

            case 0x6E:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                    
                }
                regs.l = pins.data_bus
            case 0x70:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            writeToMemoryIX(regs.b)
                            return
                        case 0xFD:
                            writeToMemoryIY(regs.b)
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                }
            case 0x71:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            writeToMemoryIX(regs.c)
                            return
                        case 0xFD:
                            writeToMemoryIY(regs.c)
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                }
            case 0x72:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            writeToMemoryIX(regs.d)
                            return
                        case 0xFD:
                            writeToMemoryIY(regs.d)
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                }
            case 0x73:
                if let pr = prefix {
                    switch pr {
                    case 0xDD:
                        if my_m_cycle == 2 {
                            writeToMemoryIX(regs.e)
                            
                            return
                        }
                    case 0xFD:
                        if my_m_cycle == 2 {
                            writeToMemoryIY(regs.e)
                            
                            return
                        }
                    case 0xED:
                        if my_m_cycle == 3 {
                            pins.address_bus = addressFromPair(buffer![1], buffer![0])
                            machine_cycle = .MemoryWrite
                            pins.data_bus = pairFromAddress(regs.sp).l
                            buffer = [pairFromAddress(regs.sp).h]
                            
                            return
                        }
                    default:
                        break
                    }
                    
                    prefix = nil
                }
            case 0x74:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            writeToMemoryIX(regs.h)
                            return
                        case 0xFD:
                            writeToMemoryIY(regs.h)
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                }
            case 0x75:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            writeToMemoryIX(regs.l)
                            return
                        case 0xFD:
                            writeToMemoryIY(regs.l)
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                }
            case 0x77:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            writeToMemoryIX(regs.a)
                            return
                        case 0xFD:
                            writeToMemoryIY(regs.a)
                            return
                        default:
                            break
                        }
                    }
                    
                    prefix = nil
                }
            case 0x7B:
                if my_m_cycle == 3 {
                    pins.address_bus = addressFromPair(buffer![1], buffer![0])
                    num_bytes = 2
                    buffer = []
                    return
                }
                
                if let pr = prefix {
                    if pr == 0xED {
                        regs.sp = addressFromPair(buffer![1], buffer![0])
                    }
                    prefix = nil
                }
            case 0x7E:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return
                        default:
                            break
                        }
                        
                    }
                    
                    prefix = nil
                    
                }
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
        num_bytes = 0
        buffer = []
        
        switch running_opcode! {
        case 0x01:
            num_bytes = 2
        case 0x02:
            pins.data_bus = regs.a
        case 0x06:
            num_bytes = 1
        case 0x0E:
            num_bytes = 1
        case 0x11:
            num_bytes = 2
        case 0x12:
            pins.data_bus = regs.a
        case 0x16:
            num_bytes = 1
        case 0x1E:
            num_bytes = 1
        case 0x21:
            num_bytes = 2
        case 0x22:
            num_bytes = 2
        case 0x26:
            num_bytes = 1
        case 0x2A:
            num_bytes = 2
        case 0x2E:
            num_bytes = 1
        case 0x31:
            num_bytes = 2
        case 0x32:
            num_bytes = 2
        case 0x36:
            if let pr = prefix {
                if pr == 0xDD || pr == 0xFD {
                    num_bytes = 2
                }
            } else {
                num_bytes = 1
            }
            
        case 0x3A:
            num_bytes = 2
        case 0x3E:
            num_bytes = 1
        case 0x40:
            regs.b = regs.b
        case 0x41:
            regs.b = regs.c
        case 0x42:
            regs.b = regs.d
        case 0x43:
            if let pr = prefix {
                if pr == 0xED {
                    num_bytes = 2
                }
            } else {
                regs.b = regs.e
            }
        case 0x44:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.b = regs.ixh
                case 0xFD:
                    regs.b = regs.iyh
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.b = regs.h
            }
        case 0x45:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.b = regs.ixl
                case 0xFD:
                    regs.b = regs.iyl
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.b = regs.l
            }
        case 0x47:
            if let pr = prefix {
                if pr == 0xDD {
                    regs.i = regs.a
                }
                
                prefix = nil
            } else {
                regs.b = regs.a
            }
        case 0x48:
            regs.c = regs.b
        case 0x49:
            regs.c = regs.c
        case 0x4A:
            regs.c = regs.d
        case 0x4B:
            if let pr = prefix {
                if pr == 0xED {
                    num_bytes = 2
                }
            } else {
                regs.c = regs.e
            }
        case 0x4C:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.c = regs.ixh
                case 0xFD:
                    regs.c = regs.iyh
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.c = regs.h
            }
        case 0x4D:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.c = regs.ixl
                case 0xFD:
                    regs.c = regs.iyl
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.c = regs.l
            }
        case 0x4F:
            if let pr = prefix {
                if pr == 0xDD {
                    regs.r = regs.a
                }
                
                prefix = nil
            } else {
                regs.c = regs.a
            }
        case 0x50:
            regs.d = regs.b
        case 0x51:
            regs.d = regs.c
        case 0x52:
            regs.d = regs.d
        case 0x53:
            if let pr = prefix {
                if pr == 0xED {
                    num_bytes = 2
                }
            } else {
                regs.d = regs.e
            }
        case 0x54:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.d = regs.ixh
                case 0xFD:
                    regs.d = regs.iyh
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.d = regs.h
            }
        case 0x55:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.d = regs.ixl
                case 0xFD:
                    regs.d = regs.iyl
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.d = regs.l
            }
        case 0x57:
            if let pr = prefix {
                if pr == 0xED {
                    regs.a = regs.i
                }
                
                prefix = nil
            } else {
                regs.d = regs.a
            }
        case 0x58:
            regs.e = regs.b
        case 0x59:
            regs.e = regs.c
        case 0x5A:
            regs.e = regs.d
        case 0x5B:
            if let pr = prefix {
                if pr == 0xED {
                    num_bytes = 2
                }
            } else {
                regs.e = regs.e
            }
        case 0x5C:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.e = regs.ixh
                case 0xFD:
                    regs.e = regs.iyh
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.e = regs.h
            }
        case 0x5D:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.e = regs.ixl
                case 0xFD:
                    regs.e = regs.iyl
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.e = regs.l
            }
        case 0x5F:
            if let pr = prefix {
                if pr == 0xED {
                    regs.a = regs.r
                }
                
                prefix = nil
            } else {
                regs.e = regs.a
            }
        case 0x60:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = regs.b
                case 0xFD:
                    regs.iyh = regs.b
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.h = regs.b
            }
        case 0x61:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = regs.c
                case 0xFD:
                    regs.iyh = regs.c
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.h = regs.c
            }
        case 0x62:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = regs.d
                case 0xFD:
                    regs.iyh = regs.d
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.h = regs.d
            }
        case 0x63:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = regs.e
                    prefix = nil
                case 0xFD:
                    regs.iyh = regs.e
                    prefix = nil
                case 0xED:
                    num_bytes = 2
                default:
                    prefix = nil
                }
            } else {
                regs.h = regs.e
            }
        case 0x64:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = regs.ixh
                case 0xFD:
                    regs.iyh = regs.iyh
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.h = regs.h
            }
        case 0x65:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = regs.ixl
                case 0xFD:
                    regs.iyh = regs.iyl
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.h = regs.l
            }
        case 0x67:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = regs.a
                case 0xFD:
                    regs.iyh = regs.a
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.h = regs.a
            }
            
        case 0x68:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = regs.b
                case 0xFD:
                    regs.iyl = regs.b
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.l = regs.b
            }
        case 0x69:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = regs.c
                case 0xFD:
                    regs.iyl = regs.c
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.l = regs.c
            }
        case 0x6A:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = regs.d
                case 0xFD:
                    regs.iyl = regs.d
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.l = regs.d
            }
        case 0x6B:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = regs.e
                    prefix = nil
                case 0xFD:
                    regs.iyl = regs.e
                    prefix = nil
                case 0xED:
                    num_bytes = 2
                default:
                    prefix = nil
                }
            } else {
                regs.l = regs.e
            }
        case 0x6C:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = regs.ixh
                case 0xFD:
                    regs.iyl = regs.iyh
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.l = regs.h
            }
        case 0x6D:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = regs.ixl
                case 0xFD:
                    regs.iyl = regs.iyl
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.l = regs.l
            }
        case 0x6F:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = regs.a
                case 0xFD:
                    regs.iyl = regs.a
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.l = regs.a
            }

        case 0x70:
            pins.data_bus = regs.b
        case 0x71:
            pins.data_bus = regs.c
        case 0x72:
            pins.data_bus = regs.d
        case 0x73:
            if let pr = prefix {
                if pr == 0xED {
                    num_bytes = 2
                }
            } else {
                pins.data_bus = regs.e
            }
        case 0x74:
            pins.data_bus = regs.h
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
            if let pr = prefix {
                if pr == 0xED {
                    num_bytes = 2
                }
            } else {
                regs.a = regs.e
            }
        case 0x7C:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.a = regs.ixh
                case 0xFD:
                    regs.a = regs.iyh
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.a = regs.h
            }
        case 0x7D:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.a = regs.ixl
                case 0xFD:
                    regs.a = regs.iyl
                default:
                    break
                }
                
                prefix = nil
            } else {
                regs.a = regs.l
            }
        case 0x7F:
            regs.a = regs.a
        case 0xF9:
            regs.sp = addressFromPair(regs.h, regs.l)
        default:
            // test for opcodes that read from memory pointed to by HL
            let opcodes_rd_hl: [UInt8] = [0x46, 0x4E, 0x56, 0x5E, 0x66, 0x6E, 0x7E]
            if opcodes_rd_hl.contains(running_opcode!) {
                if let pr = prefix {
                    if pr == 0xDD || pr == 0xFD {
                        num_bytes = 1
                    }
                } else {
                    pins.address_bus = addressFromPair(regs.h, regs.l)
                    machine_cycle = MachineCycle.MemoryRead
                }
            } else {
                switch running_opcode! {
                case 0x0A:
                    pins.address_bus = addressFromPair(regs.b, regs.c)
                    machine_cycle = MachineCycle.MemoryRead
                case 0x1A:
                    pins.address_bus = addressFromPair(regs.d, regs.e)
                    machine_cycle = MachineCycle.MemoryRead
                default:
                    break
                }
            }
        }
        
        // test for opcodes that write to memory pointed to by HL
        let opcodes_wr_hl: [UInt8] = [0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77]
        if opcodes_wr_hl.contains(running_opcode!) {
            if let pr = prefix {
                if pr == 0xDD || pr == 0xFD {
                    num_bytes = 1
                }
            } else {
                pins.address_bus = addressFromPair(regs.h, regs.l)
                machine_cycle = MachineCycle.MemoryWrite
                return
            }
            
            
        } else {
            // test for opcodes that write to memory pointed to by several pair of regs
            switch running_opcode! {
            case 0x02:
                pins.address_bus = addressFromPair(regs.b, regs.c)
                machine_cycle = MachineCycle.MemoryWrite
            case 0x12:
                pins.address_bus = addressFromPair(regs.d, regs.e)
                machine_cycle = MachineCycle.MemoryWrite
            default:
                break
            }
        }
        
        if num_bytes > 0 {
            // read parameter from PC and increment PC
            pins.address_bus = regs.pc
            // increment pc by num_bytes
            regs.pc += UInt16(num_bytes)
            machine_cycle = MachineCycle.MemoryRead
        }
    }
    
    private func opIncDec() {
        // Are we already executing an opcode ?
        if let opcode = running_opcode {
            // if so get data from data bus and store in corresponding register
            switch opcode {
            case 0x03:
                if t_cycle != 6 { return }
                regs.c = regs.c &+ 1
                regs.b = regs.c == 0 ? regs.b &+ 1 : regs.b
            case 0x0B:
                if t_cycle != 6 { return }
                regs.c = regs.c &- 1
                regs.b = regs.c == 0xFF ? regs.b &- 1 : regs.b
            case 0x13:
                if t_cycle != 6 { return }
                regs.e = regs.e &+ 1
                regs.d = regs.e == 0 ? regs.d &+ 1 : regs.d
            case 0x1B:
                if t_cycle != 6 { return }
                regs.e = regs.e &- 1
                regs.d = regs.e == 0xFF ? regs.d &- 1 : regs.d
            case 0x23:
                if t_cycle != 6 { return }
                if let pr = prefix {
                    switch pr {
                    case 0xDD:
                        regs.ixl = regs.ixl &+ 1
                        regs.ixh = regs.ixl == 0 ? regs.ixh &+ 1 : regs.ixh
                    case 0xFD:
                        regs.iyl = regs.iyl &+ 1
                        regs.iyh = regs.iyl == 0 ? regs.iyh &+ 1 : regs.iyh
                    default:
                        break
                    }
                } else {
                    regs.l = regs.l &+ 1
                    regs.h = regs.l == 0 ? regs.h &+ 1 : regs.h
                }
            case 0x2B:
                if t_cycle != 6 { return }
                regs.l = regs.l &- 1
                regs.h = regs.l == 0xFF ? regs.h &- 1 : regs.h
            case 0x33:
                if t_cycle != 6 { return }
                regs.sp = regs.sp &+ 1
            case 0x34:
                if m_cycle == 2 {
                    // data is in data bus
                    pins.data_bus = ulaCall(pins.data_bus, 1, ulaOp: .Add, ignoreCarry: true)
                    machine_cycle = .MemoryWrite
                    num_bytes = 1
                    buffer = []
                    
                    return
                }
            case 0x3B:
                if t_cycle != 6 { return }
                regs.sp = regs.sp &- 1
            default:
                break
            }
            
            // we are done with this opcode, next one please...
            machine_cycle = .OpcodeFetch
            
            return
            
        }
        
        // new opcode decoded
        running_opcode = pins.data_bus
        num_bytes = 0
        buffer = []
        machine_cycle = .UlaOperation
        
        switch running_opcode! {
        case 0x04:
            regs.b = ulaCall(regs.b, 1, ulaOp: .Add, ignoreCarry: true)
            machine_cycle = .OpcodeFetch
        case 0x05:
            regs.b = ulaCall(regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
            machine_cycle = .OpcodeFetch
        case 0x0C:
            regs.c = ulaCall(regs.c, 1, ulaOp: .Add, ignoreCarry: true)
            machine_cycle = .OpcodeFetch
        case 0x0D:
            regs.c = ulaCall(regs.c, 1, ulaOp: .Sub, ignoreCarry: true)
            machine_cycle = .OpcodeFetch
        case 0x14:
            regs.d = ulaCall(regs.d, 1, ulaOp: .Add, ignoreCarry: true)
            machine_cycle = .OpcodeFetch
        case 0x15:
            regs.d = ulaCall(regs.d, 1, ulaOp: .Sub, ignoreCarry: true)
            machine_cycle = .OpcodeFetch
        case 0x1C:
            regs.e = ulaCall(regs.e, 1, ulaOp: .Add, ignoreCarry: true)
            machine_cycle = .OpcodeFetch
        case 0x1D:
            regs.e = ulaCall(regs.e, 1, ulaOp: .Sub, ignoreCarry: true)
            machine_cycle = .OpcodeFetch
        case 0x24:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = ulaCall(regs.ixh, 1, ulaOp: .Add, ignoreCarry: true)
                case 0xFD:
                    regs.iyh = ulaCall(regs.iyh, 1, ulaOp: .Add, ignoreCarry: true)
                default:
                    break
                }
            } else {
                regs.h = ulaCall(regs.h, 1, ulaOp: .Add, ignoreCarry: true)
            }
            machine_cycle = .OpcodeFetch
        case 0x25:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixh = ulaCall(regs.ixh, 1, ulaOp: .Sub, ignoreCarry: true)
                case 0xFD:
                    regs.iyh = ulaCall(regs.iyh, 1, ulaOp: .Sub, ignoreCarry: true)
                default:
                    break
                }
            } else {
                regs.h = ulaCall(regs.h, 1, ulaOp: .Sub, ignoreCarry: true)
            }
            machine_cycle = .OpcodeFetch
        case 0x2C:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = ulaCall(regs.ixl, 1, ulaOp: .Sub, ignoreCarry: true)
                case 0xFD:
                    regs.iyl = ulaCall(regs.iyl, 1, ulaOp: .Sub, ignoreCarry: true)
                default:
                    break
                }
            } else {
                regs.l = ulaCall(regs.l, 1, ulaOp: .Add, ignoreCarry: true)
            }
            machine_cycle = .OpcodeFetch
        case 0x2D:
            if let pr = prefix {
                switch pr {
                case 0xDD:
                    regs.ixl = ulaCall(regs.ixl, 1, ulaOp: .Sub, ignoreCarry: true)
                case 0xFD:
                    regs.iyl = ulaCall(regs.iyl, 1, ulaOp: .Sub, ignoreCarry: true)
                default:
                    break
                }
            } else {
                regs.l = ulaCall(regs.l, 1, ulaOp: .Sub, ignoreCarry: true)
            }
            machine_cycle = .OpcodeFetch
        case 0x34:
            // get data pointed to by hl from memory
            pins.address_bus = addressFromPair(regs.h, regs.l)
            machine_cycle = .MemoryRead
        default:
            break
        }
        
        if num_bytes > 0 {
            // read parameter from PC and increment PC
            pins.address_bus = regs.pc
            // increment pc by num_bytes
            regs.pc += UInt16(num_bytes)
            machine_cycle = .MemoryRead
        }
    }
    
    private func ulaCall(operandA: UInt8, _ operandB: UInt8, ulaOp: UlaOp, ignoreCarry: Bool) -> UInt8 {
        /*
        Bit      0 1 2 3 4  5  6 7
        ￼￼Position S Z X H X P/V N C
        */
        var flags = regs.f.binArray
        var result: UInt8?
        
        switch ulaOp {
        case .Add:
            result = operandA &+ operandB
            flags[3] = result!.low < operandA.low ? "1" : "0"   // H (Half Carry)
            flags[5] = result! > 0x7F ? "1" : "0"               // P/V (Overflow)
            flags[6] = "0"                                      // N (Add)
            if !ignoreCarry {
                flags[7] = result! < operandA ? "1" : "0"       // C (Carry)
            }
            
        case .Sub:
            result = operandA &- operandB
            flags[3] = result!.low > operandA.low ? "1" : "0"   // H (Half Carry)
            flags[5] = result! < 0x80 ? "1" : "0"               // P/V (Overflow)
            flags[6] = "1"                                      // N (Substract)
            if !ignoreCarry {
                flags[7] = result! > operandA ? "1" : "0"       // C (Carry)
            }
            
            
        default:
            break
        }
        
        flags[0] = (result! > 0x7F) ?  "1" : "0"                // S (Sign)
        flags[1] = (result! == 0) ?  "1" : "0"                  // Z (Zero)
        
        regs.f = UInt8(flags.joinWithSeparator("").binaryToDecimal)
        
        return result!
    }
}