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

public enum Z80Error : ErrorType {
    case ZeroBytesReadFromMemory
    case ZeroBytesWriteToMemory
}

class Z80 {
    let pins = Pins()
    var program_end: Bool = false
    
    private var opcodes: Array<Void -> Bool>!
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
        initOpcodeTable()
    }
    
    func clk() throws {
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
            try memoryRead()
            
        case .MemoryWrite:
            try memoryWrite()
            
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
            processOpcode()
            
        case .MemoryRead:
            buffer!.append(pins.data_bus)
            num_bytes--
            if num_bytes > 0 {
                pins.address_bus++
                break
            }

        case .MemoryWrite:
            num_bytes--
            if buffer!.count > 0 {
                pins.data_bus = buffer![0]
                buffer!.removeFirst()
                pins.address_bus++
                break
            }
            
        case .UlaOperation:
            break
        }
        
        // continue execution of current opcode if no further access to memory needed or ula operation in progress
        if ((fixMCycle() > 1) && (num_bytes == 0)) || machine_cycle == .UlaOperation {
            processOpcode()
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

    private func processOpcode() {
        if fixMCycle() == 1 {
            // new opcode decoded
            running_opcode = pins.data_bus
            num_bytes = 0
            buffer = []
        }
        
        let eox = opcodes[Int(running_opcode!)]()
        
        // if we are in OpcodeFetch state and have to read bytes from memory
        // must be for parameters read
        if  machine_cycle == .OpcodeFetch && num_bytes > 0 {
            // read parameter from PC and increment PC
            pins.address_bus = regs.pc
            // increment pc by num_bytes
            regs.pc += UInt16(num_bytes)
            machine_cycle = .MemoryRead
        } else {
            if num_bytes == 0 && machine_cycle != .UlaOperation {
                self.machine_cycle = .OpcodeFetch
            }
        }
/*
        if eox {
            // end of execution of the current opcode
            self.machine_cycle = .OpcodeFetch
        }
*/
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
    
    private func memoryRead() throws {
        if num_bytes == 0 {
            throw Z80Error.ZeroBytesReadFromMemory
        }
        
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
    
    private func memoryWrite() throws {
        if num_bytes == 0 {
            throw Z80Error.ZeroBytesWriteToMemory
        }

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
        machine_cycle = .MemoryWrite
        num_bytes = 1
    }

    private func writeToMemoryIY(byte: UInt8) {
        pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
        pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
        pins.data_bus = byte
        buffer = []
        machine_cycle = .MemoryWrite
        num_bytes = 1
    }

    private func addressFromPair(val_h: UInt8, _ val_l: UInt8) -> UInt16 {
        return UInt16(Int(Int(val_h) * 0x100) + Int(val_l))
    }
    
    private func pairFromAddress(address: UInt16) -> (h: UInt8, l: UInt8) {
        return (UInt8(address / 0x100), UInt8(address % 0x100))
    }
    
    private func op3F() {
        print("opcode from \(pins.address_bus): \(pins.data_bus)")
    }
    
    private func opPrefix() -> Bool {
        prefix = pins.data_bus
        
        return true
    }
    
    private func fixMCycle() -> Int {
        // fix the m_cycle if we are executing prefixed opcodes
        return prefix != nil ? m_cycle - 1 : m_cycle
    }
    
    private func opLd() -> Bool {
        let my_m_cycle = fixMCycle()
        
        // Are we already executing an opcode ?
        if let opcode = running_opcode {
            // if so get data from data bus and store in corresponding register
            switch opcode {
            case 0x46:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            return false
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            return false
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
                    return false
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
                            
                            return false
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return false
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
                    
                    return false
                }
            case 0x56:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return false
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return false
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
                    return false
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
                            
                            return false
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return false
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
                    
                    return false
                }

            case 0x66:
                if let pr = prefix {
                    if my_m_cycle == 2 {
                        switch pr {
                        case 0xDD:
                            pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return false
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return false
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
                    return false
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
                            
                            return false
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return false
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
                            return false
                        case 0xFD:
                            writeToMemoryIY(regs.b)
                            return false
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
                            return false
                        case 0xFD:
                            writeToMemoryIY(regs.c)
                            return false
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
                            return false
                        case 0xFD:
                            writeToMemoryIY(regs.d)
                            return false
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
                            
                            return false
                        }
                    case 0xFD:
                        if my_m_cycle == 2 {
                            writeToMemoryIY(regs.e)
                            
                            return false
                        }
                    case 0xED:
                        if my_m_cycle == 3 {
                            pins.address_bus = addressFromPair(buffer![1], buffer![0])
                            machine_cycle = .MemoryWrite
                            pins.data_bus = pairFromAddress(regs.sp).l
                            buffer = [pairFromAddress(regs.sp).h]
                            
                            return false
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
                            return false
                        case 0xFD:
                            writeToMemoryIY(regs.h)
                            return false
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
                            return false
                        case 0xFD:
                            writeToMemoryIY(regs.l)
                            return false
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
                            return false
                        case 0xFD:
                            writeToMemoryIY(regs.a)
                            return false
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
                    return false
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
                            
                            return false
                        case 0xFD:
                            pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
                            pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
                            
                            return false
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
            
            return true
        }
        // new opcode decoded
        running_opcode = pins.data_bus
        num_bytes = 0
        buffer = []
        
        switch running_opcode! {
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
                return false
            }
            
            
        }
        
        if num_bytes > 0 {
            // read parameter from PC and increment PC
            pins.address_bus = regs.pc
            // increment pc by num_bytes
            regs.pc += UInt16(num_bytes)
            machine_cycle = MachineCycle.MemoryRead
            
            return false
        }
        
        return true
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
    
    private func initOpcodeTable() {
        opcodes = Array<Void -> Bool>(count: 0x100, repeatedValue: { return true })
        
        opcodes[0x00] = { // NOP
            print("NOP")
            return true
        }
        opcodes[0x01] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
            case 3:
                self.regs.b = self.buffer![1]
                self.regs.c = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x02] = {
            if self.fixMCycle() == 1 {
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = self.regs.a
                self.machine_cycle = .MemoryWrite
                self.num_bytes = 1
            }
            return true
        }
        opcodes[0x03] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.c = self.regs.c &+ 1
                self.regs.b = self.regs.c == 0 ? self.regs.b &+ 1 : self.regs.b
                self.machine_cycle = .OpcodeFetch
            }
            return true
        }
        opcodes[0x04] = {
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Add, ignoreCarry: true)
            return true
        }
        opcodes[0x05] = {
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
            return true
        }
        opcodes[0x06] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
            case 2:
                self.regs.b = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x0A] = {
            switch self.fixMCycle() {
            case 1:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.num_bytes = 1
                self.buffer = []
                self.machine_cycle = .MemoryRead
            case 2:
                self.regs.a = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x0B] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.c = self.regs.c &- 1
                self.regs.b = self.regs.c == 0xFF ? self.regs.b &- 1 : self.regs.b
                self.machine_cycle = .OpcodeFetch
            }
            return true
        }
        opcodes[0x0C] = {
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Add, ignoreCarry: true)
            return true
        }
        opcodes[0x0D] = {
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Sub, ignoreCarry: true)
            return true
        }
        opcodes[0x0E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
            case 2:
                self.regs.c = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x11] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
            case 3:
                self.regs.d = self.buffer![1]
                self.regs.e = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x12] = {
            if self.fixMCycle() == 1 {
                self.pins.address_bus = self.addressFromPair(self.regs.d, self.regs.e)
                self.pins.data_bus = self.regs.a
                self.machine_cycle = .MemoryWrite
                self.num_bytes = 1
            }
            return true
        }
        opcodes[0x13] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.e = self.regs.e &+ 1
                self.regs.d = self.regs.e == 0 ? self.regs.d &+ 1 : self.regs.d
                self.machine_cycle = .OpcodeFetch
            }
            return true
        }
        opcodes[0x14] = {
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Add, ignoreCarry: true)
            return true
        }
        opcodes[0x15] = {
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Sub, ignoreCarry: true)
            return true
        }
        opcodes[0x16] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
            case 2:
                self.regs.d = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x1A] = {
            switch self.fixMCycle() {
            case 1:
                self.pins.address_bus = self.addressFromPair(self.regs.d, self.regs.e)
                self.num_bytes = 1
                self.buffer = []
                self.machine_cycle = .MemoryRead
            case 2:
                self.regs.a = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x1B] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.e = self.regs.e &- 1
                self.regs.d = self.regs.e == 0xFF ? self.regs.d &- 1 : self.regs.d
                self.machine_cycle = .OpcodeFetch
            }
            return true
        }
        opcodes[0x1C] = {
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Add, ignoreCarry: true)
            return true
        }
        opcodes[0x1D] = {
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Sub, ignoreCarry: true)
            return true
        }
        opcodes[0x1E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
            case 2:
                self.regs.e = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x21] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
            case 3:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.regs.ixh = self.buffer![1]
                        self.regs.ixl = self.buffer![0]
                    case 0xFD:
                        self.regs.iyh = self.buffer![1]
                        self.regs.iyl = self.buffer![0]
                    default:
                        break
                    }
                    self.prefix = nil
                } else {
                    self.regs.h = self.buffer![1]
                    self.regs.l = self.buffer![0]
                }
            default:
                break
            }
            return true
        }
        opcodes[0x22] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
            case 3:
                self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                self.num_bytes = 2
                self.machine_cycle = .MemoryWrite
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.pins.data_bus = self.regs.ixl
                        self.buffer = [self.regs.ixh]
                    case 0xFD:
                        self.pins.data_bus = self.regs.iyl
                        self.buffer = [self.regs.iyh]
                    default:
                        break
                    }
                    self.prefix = nil
                } else {
                    self.pins.data_bus = self.regs.l
                    self.buffer = [self.regs.h]
                }
            default:
                break
            }
            return true
        }
        opcodes[0x23] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.regs.ixl = self.regs.ixl &+ 1
                        self.regs.ixh = self.regs.ixl == 0 ? self.regs.ixh &+ 1 : self.regs.ixh
                    case 0xFD:
                        self.regs.iyl = self.regs.iyl &+ 1
                        self.regs.iyh = self.regs.iyl == 0 ? self.regs.iyh &+ 1 : self.regs.iyh
                    default:
                        break
                    }
                } else {
                    self.regs.l = self.regs.l &+ 1
                    self.regs.h = self.regs.l == 0 ? self.regs.h &+ 1 : self.regs.h
                }
                self.machine_cycle = .OpcodeFetch
            }
            return true
        }
        opcodes[0x24] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixh = self.ulaCall(self.regs.ixh, 1, ulaOp: .Add, ignoreCarry: true)
                case 0xFD:
                    self.regs.iyh = self.ulaCall(self.regs.iyh, 1, ulaOp: .Add, ignoreCarry: true)
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Add, ignoreCarry: true)
            }
            return true
        }
        opcodes[0x25] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixh = self.ulaCall(self.regs.ixh, 1, ulaOp: .Sub, ignoreCarry: true)
                case 0xFD:
                    self.regs.iyh = self.ulaCall(self.regs.iyh, 1, ulaOp: .Sub, ignoreCarry: true)
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Sub, ignoreCarry: true)
            }
            return true
        }
        opcodes[0x26] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                return false
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.regs.ixh = self.buffer![0]
                    case 0xFD:
                        self.regs.iyh = self.buffer![0]
                    default:
                        break
                    }
                    self.prefix = nil
                } else {
                    self.regs.h = self.buffer![0]
                }
            default:
                break
            }
            return true
        }
        opcodes[0x2A] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
                return false
            case 3:
                self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                self.num_bytes = 2
                self.buffer = []
                return false
            case 5:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.regs.ixl = self.buffer![0]
                        self.regs.ixh = self.buffer![1]
                    case 0xFD:
                        self.regs.iyl = self.buffer![0]
                        self.regs.iyh = self.buffer![1]
                    default:
                        break
                    }
                    self.prefix = nil
                } else {
                    self.regs.l = self.buffer![0]
                    self.regs.h = self.buffer![1]
                }
            default:
                return false
            }
            return true
        }
        opcodes[0x2B] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.l = self.regs.l &- 1
                self.regs.h = self.regs.l == 0xFF ? self.regs.h &- 1 : self.regs.h
                self.machine_cycle = .OpcodeFetch
            }
            return true
        }
        opcodes[0x2C] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixl = self.ulaCall(self.regs.ixl, 1, ulaOp: .Add, ignoreCarry: true)
                case 0xFD:
                    self.regs.iyl = self.ulaCall(self.regs.iyl, 1, ulaOp: .Add, ignoreCarry: true)
                default:
                    break
                }
            } else {
                self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Add, ignoreCarry: true)
            }
            return true
        }
        opcodes[0x2D] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixl = self.ulaCall(self.regs.ixl, 1, ulaOp: .Sub, ignoreCarry: true)
                case 0xFD:
                    self.regs.iyl = self.ulaCall(self.regs.iyl, 1, ulaOp: .Sub, ignoreCarry: true)
                default:
                    break
                }
            } else {
                self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Sub, ignoreCarry: true)
            }
            return true
        }
        opcodes[0x2E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                return false
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.regs.ixl = self.buffer![0]
                    case 0xFD:
                        self.regs.iyl = self.buffer![0]
                    default:
                        break
                    }
                    self.prefix = nil
                } else {
                    self.regs.l = self.buffer![0]
                }
            default:
                break
            }
            return true
        }
        opcodes[0x31] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
            case 3:
                self.regs.sp = self.addressFromPair(self.buffer![1], self.buffer![0])
            default:
                break
            }
            return true
        }
        opcodes[0x32] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
            case 3:
                self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                self.pins.data_bus = self.regs.a
                self.buffer = []
                self.machine_cycle = .MemoryWrite
                self.num_bytes = 1
            default:
                break
            }
            return true
        }
        opcodes[0x33] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle != 6 {
                self.regs.sp = self.regs.sp &+ 1
                self.machine_cycle = .OpcodeFetch
            }
            return true
        }
        opcodes[0x34] = {
            switch self.fixMCycle() {
            case 1:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.num_bytes = 1
                self.machine_cycle = .MemoryRead
            case 2:
                // data is in data bus
                self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Add, ignoreCarry: true)
                self.machine_cycle = .MemoryWrite
                self.num_bytes = 1
                self.buffer = []
            default:
                break
            }
            return true
        }
        opcodes[0x36] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xDD || pr == 0xFD {
                        self.num_bytes = 2
                    }
                } else {
                    self.num_bytes = 1
                }
            case 2:
                if self.prefix == nil {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.pins.data_bus = self.buffer![0]
                    self.buffer = []
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 3:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.writeToMemoryIX(self.buffer![1])
                    case 0xFD:
                        self.writeToMemoryIY(self.buffer![1])
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            return true
        }
        opcodes[0x3A] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
            case 3:
                self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                self.num_bytes = 1
                self.buffer = []
                self.machine_cycle = .MemoryRead
            case 4:
                self.regs.a = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x3B] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.sp = self.regs.sp &- 1
                self.machine_cycle = .OpcodeFetch
            }
            return true
        }
        opcodes[0x3E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                return false
            case 2:
                self.regs.a = self.buffer![0]
            default:
                break
            }
            return true
        }
        opcodes[0x40] = {
            self.regs.b = self.regs.b
            return true
        }
        opcodes[0x41] = {
            self.regs.b = self.regs.c
            return true
        }
        opcodes[0x42] = {
            self.regs.b = self.regs.d
            return true
        }
        opcodes[0x43] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.num_bytes = 2
                    }
                } else {
                    self.regs.b = self.regs.e
                }
            case 3:
                if let pr = self.prefix {
                    switch pr {
                    case 0xED:
                        self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                        self.machine_cycle = .MemoryWrite
                        self.num_bytes = 2
                        self.pins.data_bus = self.regs.c
                        self.buffer = [self.regs.b]
                        
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            return true
        }
        opcodes[0x44] = opLd
        opcodes[0x45] = opLd
        opcodes[0x46] = opLd
        opcodes[0x47] = opLd
        opcodes[0x48] = opLd
        opcodes[0x49] = opLd
        opcodes[0x4A] = opLd
        opcodes[0x4B] = opLd
        opcodes[0x4C] = opLd
        opcodes[0x4D] = opLd
        opcodes[0x4E] = opLd
        opcodes[0x4F] = opLd
        opcodes[0x50] = opLd
        opcodes[0x51] = opLd
        opcodes[0x52] = opLd
        opcodes[0x53] = opLd
        opcodes[0x54] = opLd
        opcodes[0x55] = opLd
        opcodes[0x56] = opLd
        opcodes[0x57] = opLd
        opcodes[0x58] = opLd
        opcodes[0x59] = opLd
        opcodes[0x5A] = opLd
        opcodes[0x5B] = opLd
        opcodes[0x5C] = opLd
        opcodes[0x5D] = opLd
        opcodes[0x5E] = opLd
        opcodes[0x5F] = opLd
        opcodes[0x60] = opLd
        opcodes[0x61] = opLd
        opcodes[0x62] = opLd
        opcodes[0x63] = opLd
        opcodes[0x64] = opLd
        opcodes[0x65] = opLd
        opcodes[0x66] = opLd
        opcodes[0x67] = opLd
        opcodes[0x68] = opLd
        opcodes[0x69] = opLd
        opcodes[0x6A] = opLd
        opcodes[0x6B] = opLd
        opcodes[0x6C] = opLd
        opcodes[0x6D] = opLd
        opcodes[0x6E] = opLd
        opcodes[0x6F] = opLd
        opcodes[0x70] = opLd
        opcodes[0x71] = opLd
        opcodes[0x72] = opLd
        opcodes[0x73] = opLd
        opcodes[0x74] = opLd
        opcodes[0x75] = opLd
        opcodes[0x76] = {
            print("HALT !!")
            self.program_end = true
            return true
        }
        opcodes[0x77] = opLd
        opcodes[0x78] = opLd
        opcodes[0x79] = opLd
        opcodes[0x7A] = opLd
        opcodes[0x7B] = opLd
        opcodes[0x7C] = opLd
        opcodes[0x7D] = opLd
        opcodes[0x7E] = opLd
        opcodes[0x7F] = opLd
        opcodes[0xDD] = opPrefix
        opcodes[0xED] = opPrefix
        opcodes[0xFD] = opPrefix
        opcodes[0xF9] = {
            self.regs.sp = self.addressFromPair(self.regs.h, self.regs.l)
            return true
        }
    }
}