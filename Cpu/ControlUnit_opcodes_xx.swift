//
//  cu_opcodes_dd.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 15/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

// t_cycle = 8 ((DD)4, (Op)4)
extension Z80 {
    func initOpcodeTableXX(inout opcodes: OpcodeTable) {
        opcodes[0x09] = { // ADD xx,BC
            self.t_cycle += 7
            self.regs.xx = self.ulaCall16(self.regs.xx, self.regs.bc, ulaOp: .Add)
        }
        opcodes[0x19] = { // ADD xx,DE
            self.t_cycle += 7
            self.regs.xx = self.ulaCall16(self.regs.xx, self.regs.de, ulaOp: .Add)
        }
        opcodes[0x21] = { // LD xx,&0000
            self.t_cycle += 6
            self.regs.xx = self.addressFromPair(self.dataBus.read(self.regs.pc + 1), self.dataBus.read(self.regs.pc))
            self.regs.pc += 2
        }
        opcodes[0x22] = { // LD (&0000),xx
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
                self.pins.data_bus = self.regs.xxl
            case 5:
                self.pins.address_bus += 1
                self.pins.data_bus = self.regs.xxh
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x23] = { // INC xx
            self.machine_cycle = .TimeWait
            
            if self.t_cycle == 6 {
                self.regs.xxl = self.regs.xxl &+ 1
                self.regs.xxh = self.regs.xxl == 0 ? self.regs.xxh &+ 1 : self.regs.xxh
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x24] = { // INC xxH
            self.regs.xxh = self.ulaCall(self.regs.xxh, 1, ulaOp: .Add, ignoreCarry: true)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x25] = { // DEC xxH
            self.regs.xxh = self.ulaCall(self.regs.xxh, 1, ulaOp: .Sub, ignoreCarry: true)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x26] = { // LD xxH,&00
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            default:
                self.regs.xxh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x29] = { // ADD xx,xx
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
                    let xx = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    let result = self.ulaCall16(xx, xx, ulaOp: .Add)
                    self.regs.xxh = result.high
                    self.regs.xxl = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = table_NONE
                }
            }
        }
        opcodes[0x2A] = { // LD xx,(&0000)
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
                self.regs.xxl = self.pins.data_bus
                self.pins.address_bus += 1
            default:
                self.regs.xxh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x2B] = { // DEC xx
            self.machine_cycle = .TimeWait
            
            if self.t_cycle == 6 {
                self.regs.xxl = self.regs.xxl &- 1
                self.regs.xxh = self.regs.xxl == 0xFF ? self.regs.xxh &- 1 : self.regs.xxh
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x2C] = { // INC xxL
            self.regs.xxl = self.ulaCall(self.regs.xxl, 1, ulaOp: .Add, ignoreCarry: true)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x2D] = { // DEC xxL
            self.regs.xxl = self.ulaCall(self.regs.xxl, 1, ulaOp: .Sub, ignoreCarry: true)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x2E] = { // LD xxL,&00
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            default:
                self.regs.xxl = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x34] = { // INC (xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.pins.data_bus.comp2))
                self.machine_cycle = .MemoryRead
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.machine_cycle = .UlaOperation
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Add, ignoreCarry: true)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x35] = { // DEC (xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.pins.data_bus.comp2))
                self.machine_cycle = .MemoryRead
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.machine_cycle = .UlaOperation
                }
            case 5:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.data_bus = self.ulaCall(self.pins.data_bus, 1, ulaOp: .Sub, ignoreCarry: true)
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x36] = { // LD (xx+0),&00
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x39] = { // ADD xx,SP
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
                    let xx = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    let result = self.ulaCall16(xx, self.regs.sp, ulaOp: .Add)
                    self.regs.xxh = result.high
                    self.regs.xxl = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = table_NONE
                }
            }
        }
        opcodes[0x44] = { // LD B,xxH
            self.regs.b = self.regs.xxh
            self.id_opcode_table = table_NONE
        }
        opcodes[0x45] = { // LD B,xxL
            self.regs.b = self.regs.xxl
            self.id_opcode_table = table_NONE
        }
        opcodes[0x46] = { // LD B,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.b = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x4C] = { // LD C,xxH
            self.regs.c = self.regs.xxh
            self.id_opcode_table = table_NONE
        }
        opcodes[0x4D] = { // LD C,xxL
            self.regs.c = self.regs.xxl
            self.id_opcode_table = table_NONE
        }
        opcodes[0x4E] = { // LD C,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.c = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x54] = { // LD D,xxH
            self.regs.d = self.regs.xxh
            self.id_opcode_table = table_NONE
        }
        opcodes[0x55] = { // LD D,xxL
            self.regs.d = self.regs.xxl
            self.id_opcode_table = table_NONE
        }
        opcodes[0x56] = { // LD D,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.d = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x5C] = { // LD E,xxH
            self.regs.e = self.regs.xxh
            self.id_opcode_table = table_NONE
        }
        opcodes[0x5D] = { // LD E,xxL
            self.regs.e = self.regs.xxl
            self.id_opcode_table = table_NONE
        }
        opcodes[0x5E] = { // LD E,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.e = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x60] = { // LD xxH,B
            self.regs.xxh = self.regs.b
            self.id_opcode_table = table_NONE
        }
        opcodes[0x61] = { // LD xxH,C
            self.regs.xxh = self.regs.c
            self.id_opcode_table = table_NONE
        }
        opcodes[0x62] = { // LD xxH,D
            self.regs.xxh = self.regs.d
            self.id_opcode_table = table_NONE
        }
        opcodes[0x63] = { // LD xxH,E
            self.regs.xxh = self.regs.e
            self.id_opcode_table = table_NONE
        }
        opcodes[0x64] = { // LD xxH,xxH
            self.regs.xxh = self.regs.xxh
            self.id_opcode_table = table_NONE
        }
        opcodes[0x65] = { // LD xxH,xxL
            self.regs.xxh = self.regs.xxl
            self.id_opcode_table = table_NONE
        }
        opcodes[0x66] = { // LD H,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.h = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x67] = { // LD xxH,A
            self.regs.xxh = self.regs.a
            self.id_opcode_table = table_NONE
        }
        opcodes[0x68] = { // LD xxL,B
            self.regs.xxl = self.regs.b
            self.id_opcode_table = table_NONE
        }
        opcodes[0x69] = { // LD xxL,C
            self.regs.xxl = self.regs.c
            self.id_opcode_table = table_NONE
        }
        opcodes[0x6A] = { // LD xxL,D
            self.regs.xxl = self.regs.d
            self.id_opcode_table = table_NONE
        }
        opcodes[0x6B] = { // LD xxL,E
            self.regs.xxl = self.regs.e
            self.id_opcode_table = table_NONE
        }
        opcodes[0x6C] = { // LD xxL,xxH
            self.regs.xxl = self.regs.xxh
            self.id_opcode_table = table_NONE
        }
        opcodes[0x6D] = { // LD xxL,xxL
            self.regs.xxl = self.regs.xxl
            self.id_opcode_table = table_NONE
        }
        opcodes[0x6E] = { // LD L,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.l = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x6F] = { // LD xxL,A
            self.regs.xxl = self.regs.a
            self.id_opcode_table = table_NONE
        }
        opcodes[0x70] = { // LD (xx+0),B
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x71] = { // LD (xx+0),C
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x72] = { // LD (xx+0),D
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x73] = { // LD (xx+0),E
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x74] = { // LD (xx+0),H
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x75] = { // LD (xx+0),L
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x77] = { // LD (xx+0),A
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x7C] = { // LD A,xxH
            self.regs.a = self.regs.xxh
            self.id_opcode_table = table_NONE
        }
        opcodes[0x7D] = { // LD A,xxL
            self.regs.a = self.regs.xxl
            self.id_opcode_table = table_NONE
        }
        opcodes[0x7E] = { // LD A,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x84] = { // ADD A,xxH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxh, ulaOp: .Add, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x85] = { // ADD A,xxL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxl, ulaOp: .Add, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x86] = { // ADD A,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Add, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x8C] = { // ADC A,xxH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxh, ulaOp: .Adc, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x8D] = { // ADC A,xxL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxl, ulaOp: .Adc, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x8E] = { // ADC A,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Adc, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x94] = { // SUB A,xxH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxh, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x95] = { // SUB A,xxL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxl, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x96] = { // SUB A,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0x9C] = { // SBC A,xxH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxh, ulaOp: .Sbc, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x9D] = { // SBC A,xxL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxl, ulaOp: .Sbc, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0x9E] = { // SBC A,(xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sbc, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0xA4] = { // AND xxH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxh, ulaOp: .And, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0xA5] = { // AND xxL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxl, ulaOp: .And, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0xA6] = { // AND (xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .And, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0xAC] = { // XOR xxH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxh, ulaOp: .Xor, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0xAD] = { // XOR xxL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxl, ulaOp: .Xor, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0xAE] = { // XOR (xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Xor, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0xB4] = { // OR xxH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxh, ulaOp: .Or, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0xB5] = { // OR xxL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.xxl, ulaOp: .Or, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0xB6] = { // OR (xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Or, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0xBC] = { // CP xxH
            self.ulaCall(self.regs.a, self.regs.xxh, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0xBD] = { // CP xxL
            self.ulaCall(self.regs.a, self.regs.xxl, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = table_NONE
        }
        opcodes[0xBE] = { // CP (xx+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.xxh, self.regs.xxl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0xCB] = {
            self.id_opcode_table = table_XXCB
            self.regs.pc += 1
            self.processInstruction()
        }
        opcodes[0xE1] = { // POP xx
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.regs.sp += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.regs.xxl = self.pins.data_bus
                self.pins.address_bus = self.regs.sp
                self.regs.sp += 1
            default:
                self.regs.xxh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0xE3] = { // EX (SP), xx
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.data_bus = self.regs.xxl
                self.regs.xxl = self.control_reg
                self.machine_cycle = .MemoryWrite
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.address_bus = self.regs.sp + 1
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.control_reg = self.pins.data_bus
                self.pins.data_bus = self.regs.xxh
                self.regs.xxh = self.control_reg
                self.machine_cycle = .MemoryWrite
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = table_NONE
                }
            }
        }
        opcodes[0xE5] = { // PUSH xx
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.sp -= 1
                    self.pins.address_bus = self.regs.sp
                    self.pins.data_bus = self.regs.xxh
                    self.machine_cycle = .MemoryWrite
                }
            case 3:
                self.regs.sp -= 1
                self.pins.address_bus = self.regs.sp
                self.pins.data_bus = self.regs.xxl
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = table_NONE
            }
        }
        opcodes[0xE9] = { // JP (xx)
            self.regs.pc = self.addressFromPair(self.regs.xxh, self.regs.xxl)
            self.id_opcode_table = table_NONE
        }
    }
}