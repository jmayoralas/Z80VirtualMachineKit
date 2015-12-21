//
//  ControlUnit_opcodes_cb.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension ControlUnit {
    func initOpcodeTableCB(inout opcodes: OpcodeTable) {
        opcodes[0x00] = { // RLC B
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Rlc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x01] = { // RLC C
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Rlc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x02] = { // RLC D
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Rlc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x03] = { // RLC E
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Rlc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x04] = { // RLC H
            self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Rlc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x05] = { // RLC L
            self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Rlc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x06] = { // RLC (HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rlc, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        
        opcodes[0x07] = { // RLC A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rlc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x08] = { // RRC B
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Rrc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x09] = { // RRC C
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Rrc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x0A] = { // RRC D
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Rrc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x0B] = { // RRC E
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Rrc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x0C] = { // RRC H
            self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Rrc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x0D] = { // RRC L
            self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Rrc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x0E] = { // RRC (HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rrc, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x0F] = { // RRC A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rrc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x10] = { // RL B
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Rl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x11] = { // RL C
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Rl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x12] = { // RL D
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Rl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x13] = { // RL E
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Rl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x14] = { // RL H
            self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Rl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x15] = { // RL L
            self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Rl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x16] = { // RL (HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rl, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        
        opcodes[0x17] = { // RL A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x18] = { // RR B
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Rr, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x19] = { // RR C
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Rr, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x1A] = { // RR D
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Rr, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x1B] = { // RR E
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Rr, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x1C] = { // RR H
            self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Rr, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x1D] = { // RR L
            self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Rr, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x1E] = { // RR (HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Rr, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x1F] = { // RR A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rr, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x20] = { // SLA B
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sla, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x21] = { // SLA C
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Sla, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x22] = { // SLA D
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Sla, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x23] = { // SLA E
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Sla, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x24] = { // SLA H
            self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Sla, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x25] = { // SLA L
            self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Sla, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x26] = { // SLA (HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sla, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        
        opcodes[0x27] = { // SLA A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Sla, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x28] = { // SRA B
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sra, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x29] = { // SRA C
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Sra, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2A] = { // SRA D
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Sra, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2B] = { // SRA E
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Sra, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2C] = { // SRA H
            self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Sra, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2D] = { // SRA L
            self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Sra, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2E] = { // SRA (HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sra, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2F] = { // SRA A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Sra, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x30] = { // SLS B
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Sls, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x31] = { // SLS C
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Sls, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x32] = { // SLS D
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Sls, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x33] = { // SLS E
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Sls, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x34] = { // SLS H
            self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Sls, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x35] = { // SLS L
            self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Sls, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x36] = { // SLS (HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sls, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        
        opcodes[0x37] = { // SLS A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Sls, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x38] = { // SRL B
            self.regs.b = self.ulaCall(self.regs.b, 1, ulaOp: .Srl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x39] = { // SRL C
            self.regs.c = self.ulaCall(self.regs.c, 1, ulaOp: .Srl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x3A] = { // SRL D
            self.regs.d = self.ulaCall(self.regs.d, 1, ulaOp: .Srl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x3B] = { // SRL E
            self.regs.e = self.ulaCall(self.regs.e, 1, ulaOp: .Srl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x3C] = { // SRL H
            self.regs.h = self.ulaCall(self.regs.h, 1, ulaOp: .Srl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x3D] = { // SRL L
            self.regs.l = self.ulaCall(self.regs.l, 1, ulaOp: .Srl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x3E] = { // SRL (HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Srl, ignoreCarry: false)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x3F] = { // SRL A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Srl, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x40] = { // BIT 0,B
            self.ulaCall(self.regs.b, 0, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x41] = { // BIT 0,C
            self.ulaCall(self.regs.c, 0, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x42] = { // BIT 0,D
            self.ulaCall(self.regs.d, 0, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x43] = { // BIT 0,E
            self.ulaCall(self.regs.e, 0, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x44] = { // BIT 0,H
            self.ulaCall(self.regs.h, 0, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x45] = { // BIT 0,L
            self.ulaCall(self.regs.l, 0, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x46] = { // BIT 0,(HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 0, ulaOp: .Bit, ignoreCarry: false)
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
                
            }
        }
        opcodes[0x47] = { // BIT 0,A
            self.ulaCall(self.regs.a, 0, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x48] = { // BIT 1,B
            self.ulaCall(self.regs.b, 1, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x49] = { // BIT 1,C
            self.ulaCall(self.regs.c, 1, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4A] = { // BIT 1,D
            self.ulaCall(self.regs.d, 1, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4B] = { // BIT 1,E
            self.ulaCall(self.regs.e, 1, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4C] = { // BIT 1,H
            self.ulaCall(self.regs.h, 1, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4D] = { // BIT 1,L
            self.ulaCall(self.regs.l, 1, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4E] = { // BIT 1,(HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 1, ulaOp: .Bit, ignoreCarry: false)
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
                
            }
        }
        opcodes[0x4F] = { // BIT 1,A
            self.ulaCall(self.regs.a, 1, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x50] = { // BIT 2,B
            self.ulaCall(self.regs.b, 2, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x51] = { // BIT 2,C
            self.ulaCall(self.regs.c, 2, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x52] = { // BIT 2,D
            self.ulaCall(self.regs.d, 2, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x53] = { // BIT 2,E
            self.ulaCall(self.regs.e, 2, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x54] = { // BIT 2,H
            self.ulaCall(self.regs.h, 2, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x55] = { // BIT 2,L
            self.ulaCall(self.regs.l, 2, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x56] = { // BIT 2,(HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 2, ulaOp: .Bit, ignoreCarry: false)
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
                
            }
        }
        opcodes[0x57] = { // BIT 2,A
            self.ulaCall(self.regs.a, 2, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x58] = { // BIT 3,B
            self.ulaCall(self.regs.b, 3, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x59] = { // BIT 3,C
            self.ulaCall(self.regs.c, 3, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5A] = { // BIT 3,D
            self.ulaCall(self.regs.d, 3, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5B] = { // BIT 3,E
            self.ulaCall(self.regs.e, 3, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5C] = { // BIT 3,H
            self.ulaCall(self.regs.h, 3, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5D] = { // BIT 3,L
            self.ulaCall(self.regs.l, 3, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5E] = { // BIT 3,(HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 3, ulaOp: .Bit, ignoreCarry: false)
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
                
            }
        }
        opcodes[0x5F] = { // BIT 3,A
            self.ulaCall(self.regs.a, 3, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x60] = { // BIT 4,B
            self.ulaCall(self.regs.b, 4, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x61] = { // BIT 4,C
            self.ulaCall(self.regs.c, 4, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x62] = { // BIT 4,D
            self.ulaCall(self.regs.d, 4, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x63] = { // BIT 4,E
            self.ulaCall(self.regs.e, 4, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x64] = { // BIT 4,H
            self.ulaCall(self.regs.h, 4, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x65] = { // BIT 4,L
            self.ulaCall(self.regs.l, 4, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x66] = { // BIT 4,(HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 4, ulaOp: .Bit, ignoreCarry: false)
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
                
            }
        }
        opcodes[0x67] = { // BIT 4,A
            self.ulaCall(self.regs.a, 4, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x68] = { // BIT 5,B
            self.ulaCall(self.regs.b, 5, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x69] = { // BIT 5,C
            self.ulaCall(self.regs.c, 5, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6A] = { // BIT 5,D
            self.ulaCall(self.regs.d, 5, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6B] = { // BIT 5,E
            self.ulaCall(self.regs.e, 5, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6C] = { // BIT 5,H
            self.ulaCall(self.regs.h, 5, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6D] = { // BIT 5,L
            self.ulaCall(self.regs.l, 5, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6E] = { // BIT 5,(HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 5, ulaOp: .Bit, ignoreCarry: false)
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
                
            }
        }
        opcodes[0x6F] = { // BIT 5,A
            self.ulaCall(self.regs.a, 5, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x70] = { // BIT 6,B
            self.ulaCall(self.regs.b, 6, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x71] = { // BIT 6,C
            self.ulaCall(self.regs.c, 6, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x72] = { // BIT 6,D
            self.ulaCall(self.regs.d, 6, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x73] = { // BIT 6,E
            self.ulaCall(self.regs.e, 6, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x74] = { // BIT 6,H
            self.ulaCall(self.regs.h, 6, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x75] = { // BIT 6,L
            self.ulaCall(self.regs.l, 6, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x76] = { // BIT 6,(HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 6, ulaOp: .Bit, ignoreCarry: false)
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
                
            }
        }
        opcodes[0x77] = { // BIT 6,A
            self.ulaCall(self.regs.a, 6, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x78] = { // BIT 7,B
            self.ulaCall(self.regs.b, 7, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x79] = { // BIT 7,C
            self.ulaCall(self.regs.c, 7, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7A] = { // BIT 7,D
            self.ulaCall(self.regs.d, 7, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7B] = { // BIT 7,E
            self.ulaCall(self.regs.e, 7, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7C] = { // BIT 7,H
            self.ulaCall(self.regs.h, 7, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7D] = { // BIT 7,L
            self.ulaCall(self.regs.l, 7, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7E] = { // BIT 7,(HL)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.addressFromPair(self.regs.h, self.regs.l)
                self.machine_cycle = .MemoryRead
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.ulaCall(self.pins.data_bus, 7, ulaOp: .Bit, ignoreCarry: false)
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
                
            }
        }
        opcodes[0x7F] = { // BIT 7,A
            self.ulaCall(self.regs.a, 7, ulaOp: .Bit, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }

    }
}
