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
    private var m_cycle = 0
    private var old_busreq: Bool!
    
    private var int_request: Bool = false // interruption requested
    private var int_attended: Bool = false // interruption processed
    private var running_opcode: UInt8? // current running opcode
    
    private var buffer: [UInt8]?
    private var num_bytes = 0
    private var offset_cb: UInt8?
    private var prefix: UInt8?
    private var m_cycles_to_wait: [Int] = []
    private var invalid_opcode = false
    
    init() {
        regs = Registers()
        pins = Pins()
        cu = ControlUnit(pins: pins)
        
        old_busreq = pins.busreq
        
        initOpcodeTable()
        
        regs.pc = 0x1000 // entry point to begin opcode excutions
    }
    
    func clk() {
        // program ended ?
        if program_end { return }
        
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
        
        t_cycle++
        
        switch machine_cycle {
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

    private func endMachineCycle() {
        print("address_bus: \(pins.address_bus.hexStr()) - data_bus: \(pins.data_bus.hexStr()) \(pins.data_bus.binStr) - PC: \(regs.pc.hexStr()) - M: \(m_cycle) - T: \(t_cycle) - \(machine_cycle)")
        print(" IR: \(regs.ir.hexStr())                      CNPxHxZS")
        print("  A: \(regs.a.hexStr()) \(regs.a.binStr) -   F: \(regs.f.hexStr()) \(regs.f.binStr) - SP: \(regs.sp.hexStr())")
        print("  B: \(regs.b.hexStr()) \(regs.b.binStr) -   C: \(regs.c.hexStr()) \(regs.c.binStr)")
        print("  D: \(regs.d.hexStr()) \(regs.d.binStr) -   E: \(regs.e.hexStr()) \(regs.e.binStr)")
        print("  H: \(regs.h.hexStr()) \(regs.h.binStr) -   L: \(regs.l.hexStr()) \(regs.l.binStr)")
        print("IXH: \(regs.ixh.hexStr()) \(regs.ixh.binStr) - IXL: \(regs.ixl.hexStr()) \(regs.ixl.binStr)")
        print("IYH: \(regs.iyh.hexStr()) \(regs.iyh.binStr) - IYL: \(regs.iyl.hexStr()) \(regs.iyl.binStr)")
        
        cu.processOpcode(&regs, t_cycle, m_cycle, &machine_cycle)
        if regs.ir == 0x76 { program_end = true }
        
        if machine_cycle != .TimeWait {
            t_cycle = 0
            m_cycle++
        }
        
        pins.busack = pins.busreq // Acknowledge bus requests
        int_request = pins.int // samples INT signal
        int_attended = false
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
            
            // backup data bus into instruction register
            regs.ir = pins.data_bus
            
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
        machine_cycle = .MemoryWrite
        num_bytes = 1
    }
    
    private func readFromMemoryIX() {
        pins.address_bus = addressFromPair(regs.ixh, regs.ixl)
        pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
        buffer = []
        machine_cycle = .MemoryRead
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
    
    private func readFromMemoryIY() {
        pins.address_bus = addressFromPair(regs.iyh, regs.iyl)
        pins.address_bus = UInt16(Int16(pins.address_bus) + Int16(buffer![0].comp2))
        buffer = []
        machine_cycle = .MemoryRead
        num_bytes = 1
    }

    private func addressFromPair(val_h: UInt8, _ val_l: UInt8) -> UInt16 {
        return UInt16(Int(Int(val_h) * 0x100) + Int(val_l))
    }

    private func fixMCycle() -> Int {
        // fix the m_cycle if we are executing prefixed opcodes
        var m = m_cycle
        if let pr = prefix {
            m -= 1
            if pr == 0xDC || pr == 0xFC {
                m -= 3
            }
        }
        
        return m
    }
    
    private func ulaCall16(operandA: UInt16, _ operandB: UInt16, ulaOp: UlaOp) -> UInt16 {
        let f_old = regs.f
        
        let result_l = ulaCall(operandA.low, operandB.low, ulaOp: ulaOp, ignoreCarry: false)
        
        var ulaOp_high = ulaOp
        
        switch ulaOp {
        case .Add: ulaOp_high = .Adc
        case .Sub: ulaOp_high = .Sbc
        default: break
        }
        
        let result_h = ulaCall(operandA.high, operandB.high, ulaOp: ulaOp_high, ignoreCarry: false)
        // bits S, Z and PV are not affected so restore from F backup
        self.regs.f.bit(S, newVal: f_old.bit(S))
        self.regs.f.bit(Z, newVal: f_old.bit(Z))
        self.regs.f.bit(PV, newVal: f_old.bit(PV))
        // N is reset
        self.regs.f.resetBit(N)
        
        
        return addressFromPair(result_h, result_l)
    }
    
    private func ulaCall(operandA: UInt8, _ operandB: UInt8, ulaOp: UlaOp, ignoreCarry: Bool) -> UInt8 {
        /*
        Bit      0 1 2 3 4  5  6 7
        ￼￼Position S Z X H X P/V N C
        */
        
        var result: UInt8?
        var old_carry: UInt8 = 0
        
        switch ulaOp {
        case .Adc:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Add:
            regs.f.resetBit(N) // N (Add)
            
            result = operandA &+ operandB &+ old_carry

            if result!.low < operandA.low {regs.f.setBit(H)} else {regs.f.resetBit(H)} // H (Half Carry)
            
            if result! > 0x7F { // P/V (Overflow) y S (Sign)
                regs.f.setBit(PV)
                regs.f.setBit(S)
            } else {
                regs.f.resetBit(PV)
                regs.f.resetBit(S)
            }
            
            if !ignoreCarry {
                if result! < operandA {regs.f.setBit(C)} else {regs.f.resetBit(C)} // C (Carry)
            }
            
            if result! == 0 {regs.f.setBit(Z)} else {regs.f.resetBit(Z)} // Z (Zero)

        case .Sbc:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Sub:
            regs.f.setBit(N) // N (Substract)
            
            result = operandA &- operandB &- old_carry
            if result!.low > operandA.low {regs.f.setBit(H)} else {regs.f.resetBit(H)} // H (Half Carry)
            if result! < 0x80 { // P/V (Overflow) y S (Sign)
                regs.f.setBit(PV)
                regs.f.setBit(S)
            } else {
                regs.f.resetBit(PV)
                regs.f.resetBit(S)
            }
            if !ignoreCarry {
                if result! > operandA {regs.f.setBit(C)} else {regs.f.resetBit(C)} // C (Carry)
            }
            if result! == 0 {regs.f.setBit(Z)} else {regs.f.resetBit(Z)} // Z (Zero)
        
        case .Rl:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Rlc:
            regs.f.bit(C, newVal: operandA.bit(7)) // sign bit is copied to the carry flag
            result = operandA << 1
            if ulaOp == .Rl {
                result!.bit(0, newVal: Int(old_carry)) // old carry is copied to the bit 0
            } else {
                result!.bit(0, newVal: regs.f.bit(C)) // new carry is copied to the bit 0
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            
        case .Rr:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Rrc:
            regs.f.bit(C, newVal: operandA.bit(0)) // least significant bit is copied to the carry flag
            result = operandA >> 1
            if ulaOp == .Rr {
                result!.bit(7, newVal: Int(old_carry)) // old carry is copied to the bit 7
            } else {
                result!.bit(7, newVal: regs.f.bit(C)) // new carry is copied to the bit 7
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            
        default:
            break
        }
        
        return result!
    }
    
    private func initOpcodeTable() {
        opcodes = Array<Void -> Void>(count: 0x100, repeatedValue: {})
        
        opcodes[0x00] = { // NOP
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.prefix = nil
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                }
            case 2:
                if self.prefix != nil {
                    self.regs.b = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x01] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.prefix = nil
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    self.num_bytes = 2
                }
            case 2:
                if self.prefix != nil {
                    self.regs.c = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.prefix = nil
                }
            case 3:
                self.regs.b = self.buffer![1]
                self.regs.c = self.buffer![0]
            default:
                break
            }
            
        }
        opcodes[0x02] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.prefix = nil
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 2:
                if self.prefix != nil {
                    self.regs.d = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.prefix = nil
                }
            default:
                break
            }
        }
        opcodes[0x03] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.prefix = nil
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    self.machine_cycle = .UlaOperation
                    if self.t_cycle == 6 {
                        self.regs.c = self.regs.c &+ 1
                        self.regs.b = self.regs.c == 0 ? self.regs.b &+ 1 : self.regs.b
                        self.machine_cycle = .OpcodeFetch
                    }
                }
            case 2:
                if self.prefix != nil {
                    self.regs.e = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.prefix = nil
                }
            default:
                break
            }
        }
        opcodes[0x04] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.prefix = nil
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Add, ignoreCarry: true)
                }
            case 2:
                if self.prefix != nil {
                    self.regs.h = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.prefix = nil
                }
            default:
                break
            }
        }
        opcodes[0x05] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.prefix = nil
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                }
            case 2:
                if self.prefix != nil {
                    self.regs.l = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.prefix = nil
                }
            default:
                break
            }
        }
        // ==================================================================================================================
        // ============================== COMPLETED AND TESTED OPCODES ABOVE THIS LINE ======================================
        // ==================================================================================================================
        
        opcodes[0x06] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                        self.num_bytes = 1
                        self.machine_cycle = .MemoryRead
                    case 0xDC:
                        self.offset_cb = self.buffer![0]
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.offset_cb = self.buffer![0]
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    self.num_bytes = 1
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        if self.t_cycle < 4 {
                            self.machine_cycle = .TimeWait
                        } else {
                            let byte = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                            self.pins.data_bus = byte
                            self.num_bytes = 1
                            self.machine_cycle = .MemoryWrite
                            self.prefix = nil
                        }
                    case 0xDC:
                        let byte = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.buffer![0] = self.offset_cb!
                        self.writeToMemoryIX(byte)
                        self.prefix = nil
                    case 0xFC:
                        let byte = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.buffer![0] = self.offset_cb!
                        self.writeToMemoryIY(byte)
                        self.prefix = nil
                    default:
                        break
                    }
                } else {
                    self.regs.b = self.buffer![0]
                }
            default:
                break
            }
            
        }
        opcodes[0x07] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rlc, ignoreCarry: false)
                        self.prefix = nil
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rlc, ignoreCarry: false)
                }
            case 2:
                if self.prefix != nil {
                    self.regs.a = self.ulaCall(self.buffer![0], 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.prefix = nil
                }
            default:
                break
            }
        }
        opcodes[0x08] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xCB:
                        self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Rrc, ignoreCarry: false)
                        self.prefix = nil
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    let a_ = self.regs.a_
                    let f_ = self.regs.f_
                    self.regs.a_ = self.regs.a
                    self.regs.f_ = self.regs.f
                    self.regs.a = a_
                    self.regs.f = f_
                }
            case 2:
                if self.prefix != nil {
                    self.regs.b = self.ulaCall(self.buffer![0], 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.prefix = nil
                }
            default:
                break
            }
        }
        opcodes[0x09] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.machine_cycle = .TimeWait
                        self.m_cycles_to_wait = [4,4,3]
                    case 0xFD:
                        self.machine_cycle = .TimeWait
                        self.m_cycles_to_wait = [4,4,3]
                    case 0xCB:
                        self.machine_cycle = .TimeWait
                        self.m_cycles_to_wait = [4]
                    case 0xDC:
                        self.readFromMemoryIX()
                    case 0xFC:
                        self.readFromMemoryIY()
                    default:
                        self.invalid_opcode = true
                    }
                } else {
                    self.machine_cycle = .TimeWait
                    self.m_cycles_to_wait = [4,3]
                }
            case 2:
                if self.prefix != nil {
                    self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.prefix = nil
                    self.machine_cycle = .OpcodeFetch
                    /*
                    self.regs.c = self.ulaCall(self.buffer![0], 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.prefix = nil
                    */
                }
            case 3:
                // ADD HL,BC
                let hl = self.addressFromPair(self.regs.h, self.regs.l)
                let bc = self.addressFromPair(self.regs.b, self.regs.c)
                let result = self.ulaCall16(hl, bc, ulaOp: .Add)
                self.regs.h = result.high
                self.regs.l = result.low
                self.machine_cycle = .OpcodeFetch
            case 4:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        // ADD IX,BC
                        let ix = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                        let bc = self.addressFromPair(self.regs.b, self.regs.c)
                        let result = self.ulaCall16(ix, bc, ulaOp: .Add)
                        self.regs.ixh = result.high
                        self.regs.ixl = result.low
                        self.prefix = nil
                        self.machine_cycle = .OpcodeFetch
                    case 0xFD:
                        // ADD IY,BC
                        let iy = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                        let bc = self.addressFromPair(self.regs.b, self.regs.c)
                        let result = self.ulaCall16(iy, bc, ulaOp: .Add)
                        self.regs.iyh = result.high
                        self.regs.iyl = result.low
                        self.prefix = nil
                        self.machine_cycle = .OpcodeFetch
                    default:
                        break
                    }
                }
            default:
                break
            }
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
            
        }
        opcodes[0x0B] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.c = self.regs.c &- 1
                self.regs.b = self.regs.c == 0xFF ? self.regs.b &- 1 : self.regs.b
                self.machine_cycle = .OpcodeFetch
            }
            
        }
        opcodes[0x0C] = {
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Add, ignoreCarry: true)
            
        }
        opcodes[0x0D] = {
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Sub, ignoreCarry: true)
            
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
            
        }
        opcodes[0x0F] = {
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rrc, ignoreCarry: false)
        }
        opcodes[0x10] = {
            
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
            
        }
        opcodes[0x12] = {
            if self.fixMCycle() == 1 {
                self.pins.address_bus = self.addressFromPair(self.regs.d, self.regs.e)
                self.pins.data_bus = self.regs.a
                self.machine_cycle = .MemoryWrite
                self.num_bytes = 1
            }
            
        }
        opcodes[0x13] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.e = self.regs.e &+ 1
                self.regs.d = self.regs.e == 0 ? self.regs.d &+ 1 : self.regs.d
                self.machine_cycle = .OpcodeFetch
            }
            
        }
        opcodes[0x14] = {
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Add, ignoreCarry: true)
            
        }
        opcodes[0x15] = {
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Sub, ignoreCarry: true)
            
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
            
        }
        opcodes[0x17] = {
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rl, ignoreCarry: false)
        }
        opcodes[0x18] = {
            
        }
        opcodes[0x19] = {
            
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
            
        }
        opcodes[0x1B] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.e = self.regs.e &- 1
                self.regs.d = self.regs.e == 0xFF ? self.regs.d &- 1 : self.regs.d
                self.machine_cycle = .OpcodeFetch
            }
            
        }
        opcodes[0x1C] = {
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Add, ignoreCarry: true)
            
        }
        opcodes[0x1D] = {
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Sub, ignoreCarry: true)
            
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
            
        }
        opcodes[0x1F] = {
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rr, ignoreCarry: false)
        }
        opcodes[0x20] = {
            
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
            
        }
        opcodes[0x26] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
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
            
        }
        opcodes[0x27] = {
            
        }
        opcodes[0x28] = {
            
        }
        opcodes[0x29] = {
            
        }
        opcodes[0x2A] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 2
            case 3:
                self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                self.num_bytes = 2
                self.buffer = []
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
                break
            }
            
        }
        opcodes[0x2B] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.l = self.regs.l &- 1
                self.regs.h = self.regs.l == 0xFF ? self.regs.h &- 1 : self.regs.h
                self.machine_cycle = .OpcodeFetch
            }
            
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
            
        }
        opcodes[0x2E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
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
            
        }
        opcodes[0x2F] = {
            
        }
        opcodes[0x30] = {
            
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
            
        }
        opcodes[0x33] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle != 6 {
                self.regs.sp = self.regs.sp &+ 1
                self.machine_cycle = .OpcodeFetch
            }
            
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
            
        }
        opcodes[0x35] = {
            
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
            
        }
        opcodes[0x37] = {
            
        }
        opcodes[0x38] = {
            
        }
        opcodes[0x39] = {
            
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
            
        }
        opcodes[0x3B] = {
            self.machine_cycle = .UlaOperation
            if self.t_cycle == 6 {
                self.regs.sp = self.regs.sp &- 1
                self.machine_cycle = .OpcodeFetch
            }
            
        }
        opcodes[0x3C] = {
            
        }
        opcodes[0x3D] = {
            
        }
        opcodes[0x3E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
            case 2:
                self.regs.a = self.buffer![0]
            default:
                break
            }
            
        }
        opcodes[0x3F] = {
            
        }
        opcodes[0x40] = {
            self.regs.b = self.regs.b
            
        }
        opcodes[0x41] = {
            self.regs.b = self.regs.c
            
        }
        opcodes[0x42] = {
            self.regs.b = self.regs.d
            
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
            
        }
        opcodes[0x44] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.b = self.regs.ixh
                case 0xFD:
                    self.regs.b = self.regs.iyh
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.b = self.regs.h
            }
            
        }
        opcodes[0x45] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.b = self.regs.ixl
                case 0xFD:
                    self.regs.b = self.regs.iyl
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.b = self.regs.l
            }
            
        }
        opcodes[0x46] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                if self.prefix == nil {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    case 0xFD:
                        self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    default:
                        break
                    }
                    self.num_bytes = 1
                } else {
                    self.regs.b = self.buffer![0]
                }
            case 3:
                self.regs.b = self.pins.data_bus
                self.prefix = nil
            default:
                break
            }
            
        }
        opcodes[0x47] = {
            if let pr = self.prefix {
                if pr == 0xED {
                    self.regs.i = self.regs.a
                }
                self.prefix = nil
            } else {
                self.regs.b = self.regs.a
            }
            
        }
        opcodes[0x48] = {
            self.regs.c = self.regs.b
            
        }
        opcodes[0x49] = {
            self.regs.c = self.regs.c
            
        }
        opcodes[0x4A] = {
            self.regs.c = self.regs.d
            
        }
        opcodes[0x4B] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.num_bytes = 2
                    }
                } else {
                    self.regs.c = self.regs.e
                }
            case 3:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                        self.num_bytes = 2
                        self.buffer = []
                        self.machine_cycle = .MemoryRead
                    }
                }
            case 5:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.regs.c = self.buffer![0]
                        self.regs.b = self.buffer![1]
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x4C] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.c = self.regs.ixh
                case 0xFD:
                    self.regs.c = self.regs.iyh
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.c = self.regs.h
            }
            
        }
        opcodes[0x4D] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.c = self.regs.ixl
                case 0xFD:
                    self.regs.c = self.regs.iyl
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.c = self.regs.l
            }
            
        }
        opcodes[0x4E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                if self.prefix == nil {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    case 0xFD:
                        self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    default:
                        break
                    }
                    self.num_bytes = 1
                } else {
                    self.regs.c = self.buffer![0]
                }
            case 3:
                self.regs.c = self.pins.data_bus
                self.prefix = nil
            default:
                break
            }
            
        }
        opcodes[0x4F] = {
            if let pr = self.prefix {
                if pr == 0xED {
                    self.regs.r = self.regs.a
                }
                self.prefix = nil
            } else {
                self.regs.c = self.regs.a
            }
            
        }
        opcodes[0x50] = {
            self.regs.d = self.regs.b
            
        }
        opcodes[0x51] = {
            self.regs.d = self.regs.c
            
        }
        opcodes[0x52] = {
            self.regs.d = self.regs.d
            
        }
        opcodes[0x53] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.num_bytes = 2
                    }
                } else {
                    self.regs.d = self.regs.e
                }
            case 3:
                if let pr = self.prefix {
                    switch pr {
                    case 0xED:
                        self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                        self.machine_cycle = .MemoryWrite
                        self.num_bytes = 2
                        self.pins.data_bus = self.regs.e
                        self.buffer = [self.regs.d]
                        
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x54] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.d = self.regs.ixh
                case 0xFD:
                    self.regs.d = self.regs.iyh
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.d = self.regs.h
            }
            
        }
        opcodes[0x55] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.d = self.regs.ixl
                case 0xFD:
                    self.regs.d = self.regs.iyl
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.d = self.regs.l
            }
            
        }
        opcodes[0x56] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                if self.prefix == nil {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    case 0xFD:
                        self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    default:
                        break
                    }
                    self.num_bytes = 1
                } else {
                    self.regs.d = self.buffer![0]
                }
            case 3:
                self.regs.d = self.pins.data_bus
                self.prefix = nil
            default:
                break
            }
            
        }
        opcodes[0x57] = {
            if let pr = self.prefix {
                if pr == 0xED {
                    self.regs.a = self.regs.i
                }
                self.prefix = nil
            } else {
                self.regs.d = self.regs.a
            }
            
        }
        opcodes[0x58] = {
            self.regs.e = self.regs.b
            
        }
        opcodes[0x59] = {
            self.regs.e = self.regs.c
            
        }
        opcodes[0x5A] = {
            self.regs.e = self.regs.d
            
        }
        opcodes[0x5B] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.num_bytes = 2
                    }
                } else {
                    self.regs.e = self.regs.e
                }
            case 3:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                        self.num_bytes = 2
                        self.buffer = []
                        self.machine_cycle = .MemoryRead
                    }
                }
            case 5:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.regs.e = self.buffer![0]
                        self.regs.d = self.buffer![1]
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x5C] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.e = self.regs.ixh
                case 0xFD:
                    self.regs.e = self.regs.iyh
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.e = self.regs.h
            }
            
        }
        opcodes[0x5D] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.e = self.regs.ixl
                case 0xFD:
                    self.regs.e = self.regs.iyl
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.e = self.regs.l
            }
            
        }
        opcodes[0x5E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                if self.prefix == nil {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    case 0xFD:
                        self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    default:
                        break
                    }
                    self.num_bytes = 1
                } else {
                    self.regs.e = self.buffer![0]
                }
            case 3:
                self.regs.e = self.pins.data_bus
                self.prefix = nil
            default:
                break
            }
            
        }
        opcodes[0x5F] = {
            if let pr = self.prefix {
                if pr == 0xED {
                    self.regs.a = self.regs.r
                }
                self.prefix = nil
            } else {
                self.regs.e = self.regs.a
            }
            
        }
        opcodes[0x60] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixh = self.regs.b
                case 0xFD:
                    self.regs.iyh = self.regs.b
                default:
                    break
                }
            } else {
                self.regs.h = self.regs.b
            }
            
        }
        opcodes[0x61] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixh = self.regs.c
                case 0xFD:
                    self.regs.iyh = self.regs.c
                default:
                    break
                }
            } else {
                self.regs.h = self.regs.c
            }
            
        }
        opcodes[0x62] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixh = self.regs.d
                case 0xFD:
                    self.regs.iyh = self.regs.d
                default:
                    break
                }
            } else {
                self.regs.h = self.regs.d
            }
            
        }
        opcodes[0x63] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.num_bytes = 2
                    }
                } else {
                    self.regs.h = self.regs.e
                }
            case 3:
                if let pr = self.prefix {
                    switch pr {
                    case 0xED:
                        self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                        self.machine_cycle = .MemoryWrite
                        self.num_bytes = 2
                        self.pins.data_bus = self.regs.l
                        self.buffer = [self.regs.h]
                        
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x64] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixh = self.regs.ixh
                case 0xFD:
                    self.regs.ixh = self.regs.iyh
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.h = self.regs.h
            }
            
        }
        opcodes[0x65] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixh = self.regs.ixl
                case 0xFD:
                    self.regs.ixh = self.regs.iyl
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.h = self.regs.l
            }
            
        }
        opcodes[0x66] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                if self.prefix == nil {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    case 0xFD:
                        self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    default:
                        break
                    }
                    self.num_bytes = 1
                } else {
                    self.regs.h = self.buffer![0]
                }
            case 3:
                self.regs.h = self.pins.data_bus
                self.prefix = nil
            default:
                break
            }
            
        }
        opcodes[0x67] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixh = self.regs.a
                case 0xFD:
                    self.regs.iyh = self.regs.a
                // case 0xED:
                    // RRD
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.h = self.regs.a
            }
            
        }
        opcodes[0x68] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixl = self.regs.b
                case 0xFD:
                    self.regs.iyl = self.regs.b
                default:
                    break
                }
            } else {
                self.regs.l = self.regs.b
            }
            
        }
        opcodes[0x69] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixl = self.regs.c
                case 0xFD:
                    self.regs.iyl = self.regs.c
                default:
                    break
                }
            } else {
                self.regs.l = self.regs.c
            }
            
        }
        opcodes[0x6A] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixl = self.regs.d
                case 0xFD:
                    self.regs.iyl = self.regs.d
                default:
                    break
                }
            } else {
                self.regs.l = self.regs.d
            }
            
        }
        opcodes[0x6B] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.num_bytes = 2
                    }
                } else {
                    self.regs.l = self.regs.e
                }
            case 3:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                        self.num_bytes = 2
                        self.buffer = []
                        self.machine_cycle = .MemoryRead
                    }
                }
            case 5:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.regs.l = self.buffer![0]
                        self.regs.h = self.buffer![1]
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x6C] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixl = self.regs.ixh
                case 0xFD:
                    self.regs.ixl = self.regs.iyh
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.l = self.regs.h
            }
            
        }
        opcodes[0x6D] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixl = self.regs.ixl
                case 0xFD:
                    self.regs.ixl = self.regs.iyl
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.l = self.regs.l
            }
            
        }
        opcodes[0x6E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                if self.prefix == nil {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    case 0xFD:
                        self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    default:
                        break
                    }
                    self.num_bytes = 1
                } else {
                    self.regs.l = self.buffer![0]
                }
            case 3:
                self.regs.l = self.pins.data_bus
                self.prefix = nil
            default:
                break
            }
            
        }
        opcodes[0x6F] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.ixl = self.regs.a
                case 0xFD:
                    self.regs.iyl = self.regs.a
                    // case 0xED:
                    // RLD
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.l = self.regs.a
            }
            
        }
        opcodes[0x70] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xDD || pr == 0xFD {
                        self.num_bytes = 1
                    }
                } else {
                    self.pins.data_bus = self.regs.b
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.writeToMemoryIX(self.regs.b)
                    case 0xFD:
                        self.writeToMemoryIY(self.regs.b)
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x71] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xDD || pr == 0xFD {
                        self.num_bytes = 1
                    }
                } else {
                    self.pins.data_bus = self.regs.c
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.writeToMemoryIX(self.regs.c)
                    case 0xFD:
                        self.writeToMemoryIY(self.regs.c)
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x72] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xDD || pr == 0xFD {
                        self.num_bytes = 1
                    }
                } else {
                    self.pins.data_bus = self.regs.d
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.writeToMemoryIX(self.regs.d)
                    case 0xFD:
                        self.writeToMemoryIY(self.regs.d)
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x73] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.num_bytes = 1
                    case 0xFD:
                        self.num_bytes = 1
                    case 0xED:
                        self.num_bytes = 2
                    default:
                        break
                    }
                } else {
                    self.pins.data_bus = self.regs.e
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.writeToMemoryIX(self.regs.e)
                        self.prefix = nil
                    case 0xFD:
                        self.writeToMemoryIY(self.regs.e)
                        self.prefix = nil
                    default:
                        break
                    }
                }
            case 3:
                if self.prefix! == 0xED {
                    self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                    self.num_bytes = 2
                    self.pins.data_bus = self.regs.sp.low
                    self.buffer = [self.regs.sp.high]
                    self.machine_cycle = .MemoryWrite
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x74] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xDD || pr == 0xFD {
                        self.num_bytes = 1
                    }
                } else {
                    self.pins.data_bus = self.regs.h
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.writeToMemoryIX(self.regs.h)
                    case 0xFD:
                        self.writeToMemoryIY(self.regs.h)
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x75] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xDD || pr == 0xFD {
                        self.num_bytes = 1
                    }
                } else {
                    self.pins.data_bus = self.regs.l
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.writeToMemoryIX(self.regs.l)
                    case 0xFD:
                        self.writeToMemoryIY(self.regs.l)
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x76] = {
            print("HALT !!")
            self.program_end = true
            
        }
        opcodes[0x77] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xDD || pr == 0xFD {
                        self.num_bytes = 1
                    }
                } else {
                    self.pins.data_bus = self.regs.a
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryWrite
                    self.num_bytes = 1
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.writeToMemoryIX(self.regs.a)
                    case 0xFD:
                        self.writeToMemoryIY(self.regs.a)
                    default:
                        break
                    }
                    self.prefix = nil
                }
            default:
                break
            }
            
        }
        opcodes[0x78] = {
            self.regs.a = self.regs.b
            
        }
        opcodes[0x79] = {
            self.regs.a = self.regs.c
            
        }
        opcodes[0x7A] = {
            self.regs.a = self.regs.d
            
        }
        opcodes[0x7B] = {
            switch self.fixMCycle() {
            case 1:
                if let pr = self.prefix {
                    if pr == 0xED {
                        self.num_bytes = 2
                    }
                } else {
                    self.regs.a = self.regs.e
                }
            case 3:
                if self.prefix! == 0xED {
                    self.pins.address_bus = self.addressFromPair(self.buffer![1], self.buffer![0])
                    self.num_bytes = 2
                    self.buffer = []
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                if self.prefix! == 0xED {
                    self.regs.sp = self.addressFromPair(self.buffer![1], self.buffer![0])
                    self.prefix = nil
                }
            default:
                break
            }
            
            
        }
        opcodes[0x7C] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.a = self.regs.ixh
                case 0xFD:
                    self.regs.a = self.regs.iyh
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.a = self.regs.h
            }
            
        }
        opcodes[0x7D] = {
            if let pr = self.prefix {
                switch pr {
                case 0xDD:
                    self.regs.a = self.regs.ixl
                case 0xFD:
                    self.regs.a = self.regs.iyl
                default:
                    break
                }
                self.prefix = nil
            } else {
                self.regs.a = self.regs.l
            }
            
        }
        opcodes[0x7E] = {
            switch self.fixMCycle() {
            case 1:
                self.num_bytes = 1
                if self.prefix == nil {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 2:
                if let pr = self.prefix {
                    switch pr {
                    case 0xDD:
                        self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    case 0xFD:
                        self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                        self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.buffer![0].comp2))
                    default:
                        break
                    }
                    self.num_bytes = 1
                } else {
                    self.regs.a = self.buffer![0]
                }
            case 3:
                self.regs.a = self.pins.data_bus
                self.prefix = nil
            default:
                break
            }
            
        }
        opcodes[0x7F] = {
            self.regs.a = self.regs.a
            
        }
        opcodes[0xCB] = {
            if let pr = self.prefix {
                switch self.fixMCycle() {
                case 1:
                    self.num_bytes = 1
                case 2:
                    self.machine_cycle = .TimeWait
                    self.m_cycles_to_wait = [5]
                case 3:
                    switch pr {
                    case 0xDD:
                        self.prefix = 0xDC
                    case 0xFD:
                        self.prefix = 0xFC
                    default:
                        break
                    }
                    self.machine_cycle = .OpcodeFetch
                default:
                    break
                }
            } else {
                self.prefix = self.pins.data_bus
            }
        }
        opcodes[0xDD] = { self.prefix = self.pins.data_bus }
        opcodes[0xED] = { self.prefix = self.pins.data_bus }
        opcodes[0xFD] = { self.prefix = self.pins.data_bus }
        opcodes[0xF9] = {
            self.regs.sp = self.addressFromPair(self.regs.h, self.regs.l)
            
        }
    }
}