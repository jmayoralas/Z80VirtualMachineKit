//
//  ControlUnit_opcodes_ed.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 23/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension ControlUnit {
    func initOpcodeTableED(inout opcodes: OpcodeTable) {
        opcodes[0x40] = { // IN B,(C)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoRead
            default:
                self.regs.b = self.pins.data_bus
                if self.pins.data_bus.bit(7) == 1 {
                    self.regs.f.setBit(S)
                } else {
                    self.regs.f.resetBit(S)
                }
                if self.pins.data_bus == 0 {
                    self.regs.f.setBit(Z)
                } else {
                    self.regs.f.resetBit(Z)
                }
                self.regs.f.bit(PV, newVal: self.checkParity(self.pins.data_bus))
                self.regs.f.resetBit(N)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x41] = { // OUT (C),B
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = self.regs.b
                self.machine_cycle = .IoWrite
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x42] = { // SBC HL,BC
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .UlaOperation
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    let hl = self.addressFromPair(self.regs.h, self.regs.l)
                    let bc = self.addressFromPair(self.regs.b, self.regs.c)
                    let result = self.ulaCall16(hl, bc, ulaOp: .Sbc)
                    self.regs.h = result.high
                    self.regs.l = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x43] = { // LD (&0000),BC
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
                self.machine_cycle = .MemoryWrite
                self.pins.data_bus = self.regs.c
            case 5:
                self.pins.address_bus += 1
                self.pins.data_bus = self.regs.b
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x44] = { // NEG
            self.regs.a = self.ulaCall(0, self.regs.a, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x45] = { // RETN
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.regs.sp += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.sp
                self.regs.sp += 1
            default:
                self.regs.IFF1 = self.regs.IFF2
                self.regs.pc = self.addressFromPair(self.pins.data_bus, self.control_reg)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x46] = { // IM 0
            self.regs.int_mode = 0
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x47] = { // LD I,A
            self.machine_cycle = .TimeWait
            if self.t_cycle == 5 {
                self.regs.i = self.regs.a
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x48] = { // IN C,(C)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoRead
            default:
                self.regs.c = self.pins.data_bus
                if self.pins.data_bus.bit(7) == 1 {
                    self.regs.f.setBit(S)
                } else {
                    self.regs.f.resetBit(S)
                }
                if self.pins.data_bus == 0 {
                    self.regs.f.setBit(Z)
                } else {
                    self.regs.f.resetBit(Z)
                }
                self.regs.f.bit(PV, newVal: self.checkParity(self.pins.data_bus))
                self.regs.f.resetBit(N)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x49] = { // OUT (C),C
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = self.regs.c
                self.machine_cycle = .IoWrite
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x4A] = { // ADC HL,BC
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .UlaOperation
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    let hl = self.addressFromPair(self.regs.h, self.regs.l)
                    let bc = self.addressFromPair(self.regs.b, self.regs.c)
                    let result = self.ulaCall16(hl, bc, ulaOp: .Adc)
                    self.regs.h = result.high
                    self.regs.l = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x4B] = { // LD BC,(&0000)
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
            case 5:
                self.regs.c = self.pins.data_bus
                self.pins.address_bus += 1
            default:
                self.regs.b = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x4C] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x4D] = { // RETI #TO-DO: signal an I/O device that the interrupt routine is completed
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.regs.sp += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.sp
                self.regs.sp += 1
            default:
                self.regs.pc = self.addressFromPair(self.pins.data_bus, self.control_reg)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x4E] = { // IM 0
            self.opcode_tables[self.id_opcode_table][0x46]()
        }
        opcodes[0x4F] = { // LD R,A
            self.machine_cycle = .TimeWait
            if self.t_cycle == 5 {
                self.regs.r = self.regs.a
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x50] = { // IN D,(C)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoRead
            default:
                self.regs.d = self.pins.data_bus
                if self.pins.data_bus.bit(7) == 1 {
                    self.regs.f.setBit(S)
                } else {
                    self.regs.f.resetBit(S)
                }
                if self.pins.data_bus == 0 {
                    self.regs.f.setBit(Z)
                } else {
                    self.regs.f.resetBit(Z)
                }
                self.regs.f.bit(PV, newVal: self.checkParity(self.pins.data_bus))
                self.regs.f.resetBit(N)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x51] = { // OUT (C),D
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = self.regs.d
                self.machine_cycle = .IoWrite
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x52] = { // SBC HL,DE
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .UlaOperation
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    let hl = self.addressFromPair(self.regs.h, self.regs.l)
                    let de = self.addressFromPair(self.regs.d, self.regs.e)
                    let result = self.ulaCall16(hl, de, ulaOp: .Sbc)
                    self.regs.h = result.high
                    self.regs.l = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x53] = { // LD (&0000),DE
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
                self.machine_cycle = .MemoryWrite
                self.pins.data_bus = self.regs.e
            case 5:
                self.pins.address_bus += 1
                self.pins.data_bus = self.regs.d
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x54] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x55] = { // RETN
            self.opcode_tables[self.id_opcode_table][0x45]()
        }
        opcodes[0x56] = { // IM 1
            self.regs.int_mode = 1
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x57] = { // LD A,I
            self.machine_cycle = .TimeWait
            if self.t_cycle == 5 {
                self.regs.a = self.regs.i
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x58] = { // IN E,(C)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoRead
            default:
                self.regs.e = self.pins.data_bus
                if self.pins.data_bus.bit(7) == 1 {
                    self.regs.f.setBit(S)
                } else {
                    self.regs.f.resetBit(S)
                }
                if self.pins.data_bus == 0 {
                    self.regs.f.setBit(Z)
                } else {
                    self.regs.f.resetBit(Z)
                }
                self.regs.f.bit(PV, newVal: self.checkParity(self.pins.data_bus))
                self.regs.f.resetBit(N)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x59] = { // OUT (C),E
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = self.regs.e
                self.machine_cycle = .IoWrite
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x5A] = { // ADC HL,DE
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .UlaOperation
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    let hl = self.addressFromPair(self.regs.h, self.regs.l)
                    let de = self.addressFromPair(self.regs.d, self.regs.e)
                    let result = self.ulaCall16(hl, de, ulaOp: .Adc)
                    self.regs.h = result.high
                    self.regs.l = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x5B] = { // LD DE,(&0000)
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
            case 5:
                self.regs.e = self.pins.data_bus
                self.pins.address_bus += 1
            default:
                self.regs.d = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x5C] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x5D] = { // RETI
            self.opcode_tables[self.id_opcode_table][0x4D]()
        }
        opcodes[0x5E] = { // IM 2
            self.regs.int_mode = 2
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5F] = { // LD A,R
            self.machine_cycle = .TimeWait
            if self.t_cycle == 5 {
                self.regs.a = self.regs.r
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x60] = { // IN H,(C)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoRead
            default:
                self.regs.h = self.pins.data_bus
                if self.pins.data_bus.bit(7) == 1 {
                    self.regs.f.setBit(S)
                } else {
                    self.regs.f.resetBit(S)
                }
                if self.pins.data_bus == 0 {
                    self.regs.f.setBit(Z)
                } else {
                    self.regs.f.resetBit(Z)
                }
                self.regs.f.bit(PV, newVal: self.checkParity(self.pins.data_bus))
                self.regs.f.resetBit(N)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x61] = { // OUT (C),H
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = self.regs.h
                self.machine_cycle = .IoWrite
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x62] = { // SBC HL,HL
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .UlaOperation
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    let hl = self.addressFromPair(self.regs.h, self.regs.l)
                    let result = self.ulaCall16(hl, hl, ulaOp: .Sbc)
                    self.regs.h = result.high
                    self.regs.l = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x63] = { // LD (&0000),HL
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
                self.machine_cycle = .MemoryWrite
                self.pins.data_bus = self.regs.l
            case 5:
                self.pins.address_bus += 1
                self.pins.data_bus = self.regs.h
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x64] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x65] = { // RETN
            self.opcode_tables[self.id_opcode_table][0x45]()
        }
        opcodes[0x66] = { // IM 0
            self.opcode_tables[self.id_opcode_table][0x46]()
        }
        opcodes[0x67] = { // RRD
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    let a = self.regs.a
                    self.regs.a = a.high + self.pins.data_bus.low
                    self.pins.data_bus = a.low * 0x10 + self.pins.data_bus.high / 0x10
                    self.regs.f.bit(S, newVal: self.regs.a.bit(7))
                    if self.regs.a == 0 {
                        self.regs.f.setBit(Z)
                    } else {
                        self.regs.f.resetBit(Z)
                    }
                    self.regs.f.resetBit(H)
                    self.regs.f.bit(PV, newVal: self.checkParity(self.regs.a))
                    self.regs.f.resetBit(N)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x68] = { // IN L,(C)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoRead
            default:
                self.regs.l = self.pins.data_bus
                if self.pins.data_bus.bit(7) == 1 {
                    self.regs.f.setBit(S)
                } else {
                    self.regs.f.resetBit(S)
                }
                if self.pins.data_bus == 0 {
                    self.regs.f.setBit(Z)
                } else {
                    self.regs.f.resetBit(Z)
                }
                self.regs.f.bit(PV, newVal: self.checkParity(self.pins.data_bus))
                self.regs.f.resetBit(N)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x69] = { // OUT (C),L
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = self.regs.l
                self.machine_cycle = .IoWrite
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x6A] = { // ADC HL,HL
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .UlaOperation
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    let hl = self.addressFromPair(self.regs.h, self.regs.l)
                    let result = self.ulaCall16(hl, hl, ulaOp: .Adc)
                    self.regs.h = result.high
                    self.regs.l = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x6B] = { // LD HL,(&0000)
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
            case 5:
                self.regs.l = self.pins.data_bus
                self.pins.address_bus += 1
            default:
                self.regs.h = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x6C] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x6D] = { // RETI
            self.opcode_tables[self.id_opcode_table][0x4D]()
        }
        opcodes[0x6E] = { // IM 0
            self.opcode_tables[self.id_opcode_table][0x46]()
        }
        opcodes[0x6F] = { // RLD
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    let a = self.regs.a
                    self.regs.a = a.high + self.pins.data_bus.high / 0x10
                    self.pins.data_bus = self.pins.data_bus.low * 0x10 + a.low
                    self.regs.f.bit(S, newVal: self.regs.a.bit(7))
                    if self.regs.a == 0 {
                        self.regs.f.setBit(Z)
                    } else {
                        self.regs.f.resetBit(Z)
                    }
                    self.regs.f.resetBit(H)
                    self.regs.f.bit(PV, newVal: self.checkParity(self.regs.a))
                    self.regs.f.resetBit(N)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x70] = { // IN _,(C)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoRead
            default:
                if self.pins.data_bus.bit(7) == 1 {
                    self.regs.f.setBit(S)
                } else {
                    self.regs.f.resetBit(S)
                }
                if self.pins.data_bus == 0 {
                    self.regs.f.setBit(Z)
                } else {
                    self.regs.f.resetBit(Z)
                }
                self.regs.f.bit(PV, newVal: self.checkParity(self.pins.data_bus))
                self.regs.f.resetBit(N)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x71] = { // OUT (C),_
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = 0
                self.machine_cycle = .IoWrite
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x72] = { // SBC HL,SP
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .UlaOperation
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    let hl = self.addressFromPair(self.regs.h, self.regs.l)
                    let result = self.ulaCall16(hl, self.regs.sp, ulaOp: .Sbc)
                    self.regs.h = result.high
                    self.regs.l = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x73] = { // LD (&0000),SP
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
                self.machine_cycle = .MemoryWrite
                self.pins.data_bus = self.regs.sp.low
            case 5:
                self.pins.address_bus += 1
                self.pins.data_bus = self.regs.sp.high
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x74] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x75] = { // RETN
            self.opcode_tables[self.id_opcode_table][0x45]()
        }
        opcodes[0x76] = { // IM 1
            self.opcode_tables[self.id_opcode_table][0x56]()
        }
        opcodes[0x77] = { // NOP
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x78] = { // IN A,(C)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoRead
            default:
                self.regs.a = self.pins.data_bus
                if self.pins.data_bus.bit(7) == 1 {
                    self.regs.f.setBit(S)
                } else {
                    self.regs.f.resetBit(S)
                }
                if self.pins.data_bus == 0 {
                    self.regs.f.setBit(Z)
                } else {
                    self.regs.f.resetBit(Z)
                }
                self.regs.f.bit(PV, newVal: self.checkParity(self.pins.data_bus))
                self.regs.f.resetBit(N)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x79] = { // OUT (C),A
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.pins.data_bus = self.regs.a
                self.machine_cycle = .IoWrite
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x7A] = { // ADC HL,SP
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .UlaOperation
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    let hl = self.addressFromPair(self.regs.h, self.regs.l)
                    let result = self.ulaCall16(hl, self.regs.sp, ulaOp: .Adc)
                    self.regs.h = result.high
                    self.regs.l = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x7B] = { // LD SP,(&0000)
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
            case 5:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus += 1
            default:
                self.regs.sp = self.addressFromPair(self.pins.data_bus, self.control_reg)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x7C] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x7D] = { // RETI
            self.opcode_tables[self.id_opcode_table][0x4D]()
        }
        opcodes[0x7E] = { // IM 2
            self.opcode_tables[self.id_opcode_table][0x5E]()
        }
        opcodes[0x7F] = { // RLD
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xA0] = { // LDI
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.d, self.regs.e)
                self.machine_cycle = .MemoryWrite
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    let f_backup = self.regs.f
                    let de = self.ulaCall16(self.pins.address_bus, 1, ulaOp: .Add)
                    self.regs.d = de.high
                    self.regs.e = de.low
                    let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Add)
                    self.regs.h = hl.high
                    self.regs.l = hl.low
                    let bc = self.ulaCall16(self.addressFromPair(self.regs.b, self.regs.c), 1, ulaOp: .Sub)
                    self.regs.b = bc.high
                    self.regs.c = bc.low
                    self.regs.f = f_backup
                    self.regs.f.resetBit(H)
                    self.regs.f.resetBit(N)
                    if bc != 0 {
                        self.regs.f.setBit(PV)
                    } else {
                        self.regs.f.resetBit(PV)
                    }
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xA1] = { // CPI
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: true)
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    let f_backup = self.regs.f
                    let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Add)
                    self.regs.h = hl.high
                    self.regs.l = hl.low
                    let bc = self.ulaCall16(self.addressFromPair(self.regs.b, self.regs.c), 1, ulaOp: .Sub)
                    self.regs.b = bc.high
                    self.regs.c = bc.low
                    self.regs.f = f_backup
                    if bc != 0 {
                        self.regs.f.setBit(PV)
                    } else {
                        self.regs.f.resetBit(PV)
                    }
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xA2] = { // INI
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                    self.machine_cycle = .IoRead
                }
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryWrite
            default:
                let f_backup = self.regs.f
                let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Add)
                self.regs.h = hl.high
                self.regs.l = hl.low
                self.regs.f = f_backup
                self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE   
            }
        }
        opcodes[0xA3] = { // OUTI
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 3:
                self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoWrite
            default:
                let f_backup = self.regs.f
                let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Add)
                self.regs.h = hl.high
                self.regs.l = hl.low
                self.regs.f = f_backup
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE   
            }
        }
        opcodes[0xA8] = { // LDD
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.d, self.regs.e)
                self.machine_cycle = .MemoryWrite
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    let f_backup = self.regs.f
                    let de = self.ulaCall16(self.pins.address_bus, 1, ulaOp: .Sub)
                    self.regs.d = de.high
                    self.regs.e = de.low
                    let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Sub)
                    self.regs.h = hl.high
                    self.regs.l = hl.low
                    let bc = self.ulaCall16(self.addressFromPair(self.regs.b, self.regs.c), 1, ulaOp: .Sub)
                    self.regs.b = bc.high
                    self.regs.c = bc.low
                    self.regs.f = f_backup
                    self.regs.f.resetBit(H)
                    self.regs.f.resetBit(N)
                    if bc != 0 {
                        self.regs.f.setBit(PV)
                    } else {
                        self.regs.f.resetBit(PV)
                    }
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xA9] = { // CPD
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: true)
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    let f_backup = self.regs.f
                    let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Sub)
                    self.regs.h = hl.high
                    self.regs.l = hl.low
                    let bc = self.ulaCall16(self.addressFromPair(self.regs.b, self.regs.c), 1, ulaOp: .Sub)
                    self.regs.b = bc.high
                    self.regs.c = bc.low
                    self.regs.f = f_backup
                    if bc != 0 {
                        self.regs.f.setBit(PV)
                    } else {
                        self.regs.f.resetBit(PV)
                    }
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xAA] = { // IND
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                    self.machine_cycle = .IoRead
                }
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryWrite
            default:
                let f_backup = self.regs.f
                let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Sub)
                self.regs.h = hl.high
                self.regs.l = hl.low
                self.regs.f = f_backup
                self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE   
            }
        }
        opcodes[0xAB] = { // OUTD
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 3:
                self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoWrite
            default:
                let f_backup = self.regs.f
                let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Sub)
                self.regs.h = hl.high
                self.regs.l = hl.low
                self.regs.f = f_backup
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE   
            }
        }
        opcodes[0xB0] = { // LDIR
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.d, self.regs.e)
                self.machine_cycle = .MemoryWrite
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    let f_backup = self.regs.f
                    let de = self.ulaCall16(self.pins.address_bus, 1, ulaOp: .Add)
                    self.regs.d = de.high
                    self.regs.e = de.low
                    let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Add)
                    self.regs.h = hl.high
                    self.regs.l = hl.low
                    let bc = self.ulaCall16(self.addressFromPair(self.regs.b, self.regs.c), 1, ulaOp: .Sub)
                    self.regs.b = bc.high
                    self.regs.c = bc.low
                    self.regs.f = f_backup
                    self.regs.f.resetBit(H)
                    self.regs.f.resetBit(N)
                    if bc != 0 {
                        self.machine_cycle = .UlaOperation
                    } else {
                        self.regs.f.resetBit(PV)
                        self.machine_cycle = .OpcodeFetch
                        self.id_opcode_table = prefix_NONE
                    }
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.pc = self.regs.pc - 2
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xB1] = { // CPIR
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: true)
                    self.machine_cycle = .UlaOperation
                }
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    let f_backup = self.regs.f
                    let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Add)
                    self.regs.h = hl.high
                    self.regs.l = hl.low
                    let bc = self.ulaCall16(self.addressFromPair(self.regs.b, self.regs.c), 1, ulaOp: .Sub)
                    self.regs.b = bc.high
                    self.regs.c = bc.low
                    self.regs.f = f_backup
                    if bc != 0 && self.regs.f.bit(Z) == 0 {
                        self.machine_cycle = .UlaOperation
                        self.regs.f.setBit(PV)
                    } else {
                        self.regs.f.resetBit(PV)
                        self.machine_cycle = .OpcodeFetch
                        self.id_opcode_table = prefix_NONE
                    }
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.pc = self.regs.pc - 2
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xB2] = { // INIR
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                    self.machine_cycle = .IoRead
                }
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryWrite
            case 4:
                let f_backup = self.regs.f
                let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Add)
                self.regs.h = hl.high
                self.regs.l = hl.low
                self.regs.f = f_backup
                self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                if self.regs.b != 0 {
                    self.machine_cycle = .UlaOperation
                    self.regs.f.setBit(PV)
                } else {
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.pc = self.regs.pc - 2
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xB3] = { // OTIR
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 3:
                self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoWrite
            case 4:
                let f_backup = self.regs.f
                let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Add)
                self.regs.h = hl.high
                self.regs.l = hl.low
                self.regs.f = f_backup
                if self.regs.b != 0 {
                    self.machine_cycle = .UlaOperation
                    self.regs.f.setBit(PV)
                } else {
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.pc = self.regs.pc - 2
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xB8] = { // LDDR
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.d, self.regs.e)
                self.machine_cycle = .MemoryWrite
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    let f_backup = self.regs.f
                    let de = self.ulaCall16(self.pins.address_bus, 1, ulaOp: .Sub)
                    self.regs.d = de.high
                    self.regs.e = de.low
                    let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Sub)
                    self.regs.h = hl.high
                    self.regs.l = hl.low
                    let bc = self.ulaCall16(self.addressFromPair(self.regs.b, self.regs.c), 1, ulaOp: .Sub)
                    self.regs.b = bc.high
                    self.regs.c = bc.low
                    self.regs.f = f_backup
                    self.regs.f.resetBit(H)
                    self.regs.f.resetBit(N)
                    if bc != 0 {
                        self.machine_cycle = .UlaOperation
                    } else {
                        self.regs.f.resetBit(PV)
                        self.machine_cycle = .OpcodeFetch
                        self.id_opcode_table = prefix_NONE
                    }
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.pc = self.regs.pc - 2
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xB9] = { // CPDR
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: true)
                    self.machine_cycle = .UlaOperation
                }
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    let f_backup = self.regs.f
                    let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Sub)
                    self.regs.h = hl.high
                    self.regs.l = hl.low
                    let bc = self.ulaCall16(self.addressFromPair(self.regs.b, self.regs.c), 1, ulaOp: .Sub)
                    self.regs.b = bc.high
                    self.regs.c = bc.low
                    self.regs.f = f_backup
                    if bc != 0 && self.regs.f.bit(Z) == 0 {
                        self.machine_cycle = .UlaOperation
                        self.regs.f.setBit(PV)
                    } else {
                        self.regs.f.resetBit(PV)
                        self.machine_cycle = .OpcodeFetch
                        self.id_opcode_table = prefix_NONE
                    }
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.pc = self.regs.pc - 2
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xBA] = { // INDR
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                    self.machine_cycle = .IoRead
                }
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryWrite
            case 4:
                let f_backup = self.regs.f
                let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Sub)
                self.regs.h = hl.high
                self.regs.l = hl.low
                self.regs.f = f_backup
                self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                if self.regs.b != 0 {
                    self.machine_cycle = .UlaOperation
                    self.regs.f.setBit(PV)
                } else {
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.pc = self.regs.pc - 2
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xBB] = { // OTDR
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                    self.machine_cycle = .MemoryRead
                }
            case 3:
                self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sub, ignoreCarry: true)
                self.pins.address_bus = self.addressFromPair(self.regs.b, self.regs.c)
                self.machine_cycle = .IoWrite
            case 4:
                let f_backup = self.regs.f
                let hl = self.ulaCall16(self.addressFromPair(self.regs.h, self.regs.l), 1, ulaOp: .Sub)
                self.regs.h = hl.high
                self.regs.l = hl.low
                self.regs.f = f_backup
                if self.regs.b != 0 {
                    self.machine_cycle = .UlaOperation
                    self.regs.f.setBit(PV)
                } else {
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.pc = self.regs.pc - 2
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
    }
}