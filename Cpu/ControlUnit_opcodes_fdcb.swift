//
//  ControlUnit_opcodes_fdcb.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 23/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension ControlUnit {
    func initOpcodeTableFDCB(inout opcodes: OpcodeTable) {
        opcodes[0x00] = { // rlc (iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x01] = { // rlc (iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x02] = { // rlc (iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x03] = { // rlc (iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x04] = { // rlc (iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x05] = { // rlc (iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x06] = { // RLC (iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x07] = { // rlc (iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x08] = { // rrc (iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x09] = { // rrc (iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x0A] = { // rrc (iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x0B] = { // rrc (iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x0C] = { // rrc (iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x0D] = { // rrc (iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x0E] = { // RRC (iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x0F] = { // rrc (iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x10] = { // rl (iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x11] = { // rl (iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x12] = { // rl (iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x13] = { // rl (iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x14] = { // rl (iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x15] = { // rl (iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x16] = { // RLC (iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x17] = { // rl (iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x18] = { // rr (iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x19] = { // rr (iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x1A] = { // rr (iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x1B] = { // rr (iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x1C] = { // rr (iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x1D] = { // rr (iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x1E] = { // RLC (iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x1F] = { // rr (iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x20] = { // sla (iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x21] = { // sla (iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x22] = { // sla (iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x23] = { // sla (iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x24] = { // sla (iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x25] = { // sla (iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x26] = { // SLA (iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x27] = { // sla (iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x28] = { // sra (iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x29] = { // sra (iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2A] = { // sra (iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2B] = { // sra (iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2C] = { // sra (iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2D] = { // sra (iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2E] = { // SRA (iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2F] = { // sra (iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x30] = { // sls (iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x31] = { // sls (iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x32] = { // sls (iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x33] = { // sls (iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x34] = { // sls (iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x35] = { // sls (iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x36] = { // SLS (iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x37] = { // sls (iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x38] = { // srl (iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x39] = { // srl (iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x3A] = { // srl (iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x3B] = { // srl (iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x3C] = { // srl (iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x3D] = { // srl (iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x3E] = { // SRL (iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x3F] = { // srl (iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x40] = { // bit 0,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x41] = { // bit 0,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x42] = { // bit 0,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x43] = { // bit 0,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x44] = { // bit 0,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x45] = { // bit 0,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x46] = { // BIT 0,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x47] = { // bit 0,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x48] = { // bit 1,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x49] = { // bit 1,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x4A] = { // bit 1,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x4B] = { // bit 1,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x4C] = { // bit 1,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x4D] = { // bit 1,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x4E] = { // BIT 1,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x4F] = { // bit 1,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x50] = { // bit 2,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x51] = { // bit 2,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x52] = { // bit 2,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x53] = { // bit 2,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x54] = { // bit 2,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x55] = { // bit 2,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x56] = { // BIT 2,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x57] = { // bit 2,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x58] = { // bit 3,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x59] = { // bit 3,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x5A] = { // bit 3,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x5B] = { // bit 3,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x5C] = { // bit 3,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x5D] = { // bit 3,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x5E] = { // BIT 3,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x5F] = { // bit 3,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x60] = { // bit 4,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x61] = { // bit 4,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x62] = { // bit 4,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x63] = { // bit 4,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x64] = { // bit 4,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x65] = { // bit 4,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x66] = { // BIT 4,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x67] = { // bit 4,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x68] = { // bit 5,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x69] = { // bit 5,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x6A] = { // bit 5,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x6B] = { // bit 5,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x6C] = { // bit 5,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x6D] = { // bit 5,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x6E] = { // BIT 5,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x6F] = { // bit 5,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x70] = { // bit 6,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x71] = { // bit 6,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x72] = { // bit 6,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x73] = { // bit 6,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x74] = { // bit 6,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x75] = { // bit 6,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x76] = { // BIT 6,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x77] = { // bit 6,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x78] = { // bit 7,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.b = self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x79] = { // bit 7,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.c = self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x7A] = { // bit 7,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.d = self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x7B] = { // bit 7,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.e = self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x7C] = { // bit 7,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.h = self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x7D] = { // bit 7,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.l = self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x7E] = { // BIT 7,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x7F] = { // bit 7,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.regs.a = self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x80] = { // res 0,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(0)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x81] = { // res 0,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(0)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x82] = { // res 0,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(0)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x83] = { // res 0,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(0)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x84] = { // res 0,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(0)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x85] = { // res 0,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(0)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x86] = { // RES 0,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(0)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x87] = { // res 0,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(0)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x88] = { // res 1,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(1)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x89] = { // res 1,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(1)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x8A] = { // res 1,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(1)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x8B] = { // res 1,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(1)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x8C] = { // res 1,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(1)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x8D] = { // res 1,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(1)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x8E] = { // RES 1,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(1)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x8F] = { // res 1,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(1)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x90] = { // res 2,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(2)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x91] = { // res 2,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(2)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x92] = { // res 2,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(2)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x93] = { // res 2,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(2)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x94] = { // res 2,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(2)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x95] = { // res 2,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(2)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x96] = { // RES 2,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(2)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x97] = { // res 2,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(2)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x98] = { // res 3,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(3)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x99] = { // res 3,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(3)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x9A] = { // res 3,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(3)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x9B] = { // res 3,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(3)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x9C] = { // res 3,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(3)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x9D] = { // res 3,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(3)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x9E] = { // RES 3,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(3)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x9F] = { // res 3,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(3)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA0] = { // res 4,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(4)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA1] = { // res 4,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(4)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA2] = { // res 4,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(4)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA3] = { // res 4,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(4)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA4] = { // res 4,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(4)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA5] = { // res 4,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(4)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA6] = { // RES 4,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(4)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA7] = { // res 4,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(4)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA8] = { // res 5,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(5)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA9] = { // res 5,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(5)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xAA] = { // res 5,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(5)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xAB] = { // res 5,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(5)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xAC] = { // res 5,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(5)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xAD] = { // res 5,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(5)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xAE] = { // RES 5,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(5)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xAF] = { // res 5,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(5)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB0] = { // res 6,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(6)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB1] = { // res 6,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(6)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB2] = { // res 6,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(6)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB3] = { // res 6,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(6)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB4] = { // res 6,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(6)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB5] = { // res 6,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(6)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB6] = { // RES 6,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(6)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB7] = { // res 6,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(6)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB8] = { // res 7,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(7)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB9] = { // res 7,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(7)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xBA] = { // res 7,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(7)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xBB] = { // res 7,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(7)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xBC] = { // res 7,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(7)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xBD] = { // res 7,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(7)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xBE] = { // RES 7,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(7)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xBF] = { // res 7,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.resetBit(7)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC0] = { // set 0,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(0)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC1] = { // set 0,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(0)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC2] = { // set 0,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(0)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC3] = { // set 0,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(0)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC4] = { // set 0,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(0)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC5] = { // set 0,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(0)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC6] = { // SET 0,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(0)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC7] = { // set 0,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(0)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC8] = { // set 1,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(1)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xC9] = { // set 1,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(1)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xCA] = { // set 1,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(1)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xCB] = { // set 1,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(1)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xCC] = { // set 1,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(1)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xCD] = { // set 1,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(1)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xCE] = { // SET 1,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(1)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xCF] = { // set 1,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(1)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD0] = { // set 2,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(2)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD1] = { // set 2,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(2)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD2] = { // set 2,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(2)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD3] = { // set 2,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(2)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD4] = { // set 2,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(2)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD5] = { // set 2,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(2)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD6] = { // SET 2,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(2)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD7] = { // set 2,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(2)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD8] = { // set 3,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(3)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xD9] = { // set 3,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(3)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xDA] = { // set 3,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(3)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xDB] = { // set 3,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(3)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xDC] = { // set 3,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(3)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xDD] = { // set 3,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(3)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xDE] = { // SET 3,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(3)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xDF] = { // set 3,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(3)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE0] = { // set 4,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(4)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE1] = { // set 4,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(4)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE2] = { // set 4,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(4)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE3] = { // set 4,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(4)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE4] = { // set 4,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(4)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE5] = { // set 4,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(4)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE6] = { // SET 4,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(4)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE7] = { // set 4,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(4)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE8] = { // set 5,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(5)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE9] = { // set 5,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(5)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xEA] = { // set 5,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(5)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xEB] = { // set 5,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(5)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xEC] = { // set 5,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(5)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xED] = { // set 5,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(5)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xEE] = { // SET 5,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(5)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xEF] = { // set 5,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(5)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF0] = { // set 6,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(6)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF1] = { // set 6,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(6)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF2] = { // set 6,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(6)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF3] = { // set 6,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(6)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF4] = { // set 6,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(6)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF5] = { // set 6,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(6)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF6] = { // SET 6,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(6)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF7] = { // set 6,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(6)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF8] = { // set 7,(iy+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(7)
                    self.regs.b = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xF9] = { // set 7,(iy+0) -> c
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(7)
                    self.regs.c = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xFA] = { // set 7,(iy+0) -> d
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(7)
                    self.regs.d = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xFB] = { // set 7,(iy+0) -> e
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(7)
                    self.regs.e = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xFC] = { // set 7,(iy+0) -> h
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(7)
                    self.regs.h = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xFD] = { // set 7,(iy+0) -> l
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(7)
                    self.regs.l = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xFE] = { // SET 7,(iy+0)
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(7)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xFF] = { // set 7,(iy+0) -> a
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus.setBit(7)
                    self.regs.a = self.pins.data_bus
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
    }
}