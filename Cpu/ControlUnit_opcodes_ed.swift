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
                self.regs.pc++
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
                self.machine_cycle = .MemoryWrite
                self.pins.data_bus = self.regs.c
            case 5:
                self.pins.address_bus++
                self.pins.data_bus = self.regs.b
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x44] = { // NEG
            self.regs.a = UInt8(self.regs.a.comp2)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x45] = { // RETN
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.regs.sp++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.sp
                self.regs.sp++
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
                self.regs.pc++
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
            case 4:
                self.pins.address_bus = self.addressFromPair(self.pins.data_bus, self.control_reg)
            case 5:
                self.regs.c = self.pins.data_bus
                self.pins.address_bus++
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
                self.regs.sp++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.sp
                self.regs.sp++
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
    }
}