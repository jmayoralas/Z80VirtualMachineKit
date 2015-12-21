//
//  cu_opcodes_dd.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 15/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension ControlUnit {
    func initOpcodeTableDD(inout opcodes: OpcodeTable) {
        opcodes[0x09] = { // ADD IX,BC
            switch self.m_cycle {
            case 2:
                fallthrough
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    var ix = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    ix = self.ulaCall16(ix, self.addressFromPair(self.regs.b, self.regs.c), ulaOp: .Add)
                    self.regs.ixh = ix.high
                    self.regs.ixl = ix.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x19] = { // ADD IX,DE
            switch self.m_cycle {
            case 2:
                fallthrough
            case 3:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.machine_cycle = .UlaOperation
                }
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 3 {
                    var ix = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    ix = self.ulaCall16(ix, self.addressFromPair(self.regs.d, self.regs.e), ulaOp: .Add)
                    self.regs.ixh = ix.high
                    self.regs.ixl = ix.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x21] = { // LD IX,&0000
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
            case 3:
                self.regs.ixl = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
            default:
                self.regs.ixh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x22] = { // LD (&0000),IX
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
                self.pins.data_bus = self.regs.ixl
            case 5:
                self.pins.address_bus++
                self.pins.data_bus = self.regs.ixh
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x23] = { // INC IX
            self.machine_cycle = .TimeWait
            
            if self.t_cycle == 6 {
                self.regs.ixl = self.regs.ixl &+ 1
                self.regs.ixh = self.regs.ixl == 0 ? self.regs.ixh &+ 1 : self.regs.ixh
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x24] = { // INC IXH
            self.regs.ixh = self.ulaCall(self.regs.ixh, 1, ulaOp: .Add, ignoreCarry: true)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x25] = { // DEC IXH
            self.regs.ixh = self.ulaCall(self.regs.ixh, 1, ulaOp: .Sub, ignoreCarry: true)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x26] = { // LD IXH,&00
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
            default:
                self.regs.ixh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x29] = { // ADD IX,IX
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
                    let ix = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    let result = self.ulaCall16(ix, ix, ulaOp: .Add)
                    self.regs.ixh = result.high
                    self.regs.ixl = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x2A] = { // LD IX,(&0000)
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
                self.regs.ixl = self.pins.data_bus
                self.pins.address_bus++
            default:
                self.regs.ixh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2B] = { // DEC IX
            self.machine_cycle = .TimeWait
            
            if self.t_cycle == 6 {
                self.regs.ixl = self.regs.ixl &- 1
                self.regs.ixh = self.regs.ixl == 0xFF ? self.regs.ixh &- 1 : self.regs.ixh
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2C] = { // INC IXL
            self.regs.ixl = self.ulaCall(self.regs.ixl, 1, ulaOp: .Add, ignoreCarry: true)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2D] = { // DEC IXL
            self.regs.ixl = self.ulaCall(self.regs.ixl, 1, ulaOp: .Sub, ignoreCarry: true)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2E] = { // LD IXL,&00
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
            default:
                self.regs.ixl = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x34] = { // INC (IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.pins.data_bus.comp2))
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
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x35] = { // DEC (IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.pins.data_bus.comp2))
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
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x36] = { // LD (IX+0),&00
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x39] = { // ADD IX,SP
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
                    let ix = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    let result = self.ulaCall16(ix, self.regs.sp, ulaOp: .Add)
                    self.regs.ixh = result.high
                    self.regs.ixl = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x44] = { // LD B,IXH
            self.regs.b = self.regs.ixh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x45] = { // LD B,IXL
            self.regs.b = self.regs.ixl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x46] = { // LD B,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.b = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x4C] = { // LD C,IXH
            self.regs.c = self.regs.ixh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4D] = { // LD C,IXL
            self.regs.c = self.regs.ixl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4E] = { // LD C,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.c = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x54] = { // LD D,IXH
            self.regs.d = self.regs.ixh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x55] = { // LD D,IXL
            self.regs.d = self.regs.ixl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x56] = { // LD D,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.d = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x5C] = { // LD E,IXH
            self.regs.e = self.regs.ixh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5D] = { // LD E,IXL
            self.regs.e = self.regs.ixl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5E] = { // LD E,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.e = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x60] = { // LD IXH,B
            self.regs.ixh = self.regs.b
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x61] = { // LD IXH,C
            self.regs.ixh = self.regs.c
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x62] = { // LD IXH,D
            self.regs.ixh = self.regs.d
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x63] = { // LD IXH,E
            self.regs.ixh = self.regs.e
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x64] = { // LD IXH,IXH
            self.regs.ixh = self.regs.ixh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x65] = { // LD IXH,IXL
            self.regs.ixh = self.regs.ixl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x66] = { // LD H,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.h = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x67] = { // LD IXH,A
            self.regs.ixh = self.regs.a
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x68] = { // LD IXL,B
            self.regs.ixl = self.regs.b
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x69] = { // LD IXL,C
            self.regs.ixl = self.regs.c
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6A] = { // LD IXL,D
            self.regs.ixl = self.regs.d
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6B] = { // LD IXL,E
            self.regs.ixl = self.regs.e
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6C] = { // LD IXL,IXH
            self.regs.ixl = self.regs.ixh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6D] = { // LD IXL,IXL
            self.regs.ixl = self.regs.ixl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6E] = { // LD L,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.l = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x6F] = { // LD IXL,A
            self.regs.ixl = self.regs.a
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x70] = { // LD (IX+0),B
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x71] = { // LD (IX+0),C
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x72] = { // LD (IX+0),D
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x73] = { // LD (IX+0),E
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x74] = { // LD (IX+0),H
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x75] = { // LD (IX+0),L
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x77] = { // LD (IX+0),A
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x7C] = { // LD A,IXH
            self.regs.a = self.regs.ixh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7D] = { // LD A,IXL
            self.regs.a = self.regs.ixl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7E] = { // LD A,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x84] = { // ADD A,IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixh, ulaOp: .Add, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x85] = { // ADD A,IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixl, ulaOp: .Add, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x86] = { // ADD A,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Add, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x8C] = { // ADC A,IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixh, ulaOp: .Adc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x8D] = { // ADC A,IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixl, ulaOp: .Adc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x8E] = { // ADC A,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Adc, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x94] = { // SUB A,IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixh, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x95] = { // SUB A,IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixl, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x96] = { // SUB A,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x9C] = { // SBC A,IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixh, ulaOp: .Sbc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x9D] = { // SBC A,IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixl, ulaOp: .Sbc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x9E] = { // SBC A,(IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sbc, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA4] = { // AND IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixh, ulaOp: .And, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xA5] = { // AND IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixl, ulaOp: .And, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xA6] = { // AND (IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .And, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xAC] = { // XOR IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixh, ulaOp: .Xor, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xAD] = { // XOR IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixl, ulaOp: .Xor, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xAE] = { // XOR (IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Xor, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB4] = { // OR IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixh, ulaOp: .Or, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xB5] = { // OR IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.ixl, ulaOp: .Or, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xB6] = { // OR (IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Or, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xBC] = { // CP IXH
            self.ulaCall(self.regs.a, self.regs.ixh, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xBD] = { // CP IXL
            self.ulaCall(self.regs.a, self.regs.ixl, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xBE] = { // CP (IX+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc++
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.machine_cycle = .UlaOperation
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE1] = { // POP IX
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.regs.sp++
                self.machine_cycle = .MemoryRead
            case 3:
                self.regs.ixl = self.pins.data_bus
                self.pins.address_bus = self.regs.sp
                self.regs.sp++
            default:
                self.regs.ixh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE3] = { // EX (SP), IX
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.data_bus = self.regs.ixl
                self.regs.ixl = self.control_reg
                self.machine_cycle = .MemoryWrite
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.address_bus = self.regs.sp + 1
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.control_reg = self.pins.data_bus
                self.pins.data_bus = self.regs.ixh
                self.regs.ixh = self.control_reg
                self.machine_cycle = .MemoryWrite
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xE5] = { // PUSH IX
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.sp--
                    self.pins.address_bus = self.regs.sp
                    self.pins.data_bus = self.regs.ixh
                    self.machine_cycle = .MemoryWrite
                }
            case 3:
                self.regs.sp--
                self.pins.address_bus = self.regs.sp
                self.pins.data_bus = self.regs.ixl
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE9] = { // JP (IX)
            self.regs.pc = self.addressFromPair(self.regs.ixh, self.regs.ixl)
            self.id_opcode_table = prefix_NONE
        }
    }
}