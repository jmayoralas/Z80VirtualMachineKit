//
//  ControlUnit_opcodes_fd.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 21/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension ControlUnit {
    func initOpcodeTableFD(inout opcodes: OpcodeTable) {
        opcodes[0x09] = { // ADD IY,BC
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
                    var iy = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    iy = self.ulaCall16(iy, self.addressFromPair(self.regs.b, self.regs.c), ulaOp: .Add)
                    self.regs.iyh = iy.high
                    self.regs.iyl = iy.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x19] = { // ADD IY,DE
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
                    var iy = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    iy = self.ulaCall16(iy, self.addressFromPair(self.regs.d, self.regs.e), ulaOp: .Add)
                    self.regs.iyh = iy.high
                    self.regs.iyl = iy.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x21] = { // LD IY,&0000
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            case 3:
                self.regs.iyl = self.pins.data_bus
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            default:
                self.regs.iyh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x22] = { // LD (&0000),IY
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
                self.pins.data_bus = self.regs.iyl
            case 5:
                self.pins.address_bus += 1
                self.pins.data_bus = self.regs.iyh
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x23] = { // INC IY
            self.machine_cycle = .TimeWait
            
            if self.t_cycle == 6 {
                self.regs.iyl = self.regs.iyl &+ 1
                self.regs.iyh = self.regs.iyl == 0 ? self.regs.iyh &+ 1 : self.regs.iyh
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x24] = { // INC IXH
            self.regs.iyh = self.ulaCall(self.regs.iyh, 1, ulaOp: .Add, ignoreCarry: true)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x25] = { // DEC IXH
            self.regs.iyh = self.ulaCall(self.regs.iyh, 1, ulaOp: .Sub, ignoreCarry: true)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x26] = { // LD IXH,&00
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            default:
                self.regs.iyh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x29] = { // ADD IY,IY
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
                    let iy = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    let result = self.ulaCall16(iy, iy, ulaOp: .Add)
                    self.regs.iyh = result.high
                    self.regs.iyl = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x2A] = { // LD IY,(&0000)
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
                self.regs.iyl = self.pins.data_bus
                self.pins.address_bus += 1
            default:
                self.regs.iyh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2B] = { // DEC IY
            self.machine_cycle = .TimeWait
            
            if self.t_cycle == 6 {
                self.regs.iyl = self.regs.iyl &- 1
                self.regs.iyh = self.regs.iyl == 0xFF ? self.regs.iyh &- 1 : self.regs.iyh
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x2C] = { // INC IXL
            self.regs.iyl = self.ulaCall(self.regs.iyl, 1, ulaOp: .Add, ignoreCarry: true)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2D] = { // DEC IXL
            self.regs.iyl = self.ulaCall(self.regs.iyl, 1, ulaOp: .Sub, ignoreCarry: true)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x2E] = { // LD IXL,&00
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .MemoryRead
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
            default:
                self.regs.iyl = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x34] = { // INC (IY+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
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
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x35] = { // DEC (IY+0)
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.pc
                self.regs.pc += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
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
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x36] = { // LD (IY+0),&00
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x39] = { // ADD IY,SP
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
                    let iy = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    let result = self.ulaCall16(iy, self.regs.sp, ulaOp: .Add)
                    self.regs.iyh = result.high
                    self.regs.iyl = result.low
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0x44] = { // LD B,IXH
            self.regs.b = self.regs.iyh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x45] = { // LD B,IXL
            self.regs.b = self.regs.iyl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x46] = { // LD B,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.b = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x4C] = { // LD C,IXH
            self.regs.c = self.regs.iyh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4D] = { // LD C,IXL
            self.regs.c = self.regs.iyl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x4E] = { // LD C,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.c = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x54] = { // LD D,IXH
            self.regs.d = self.regs.iyh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x55] = { // LD D,IXL
            self.regs.d = self.regs.iyl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x56] = { // LD D,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.d = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x5C] = { // LD E,IXH
            self.regs.e = self.regs.iyh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5D] = { // LD E,IXL
            self.regs.e = self.regs.iyl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x5E] = { // LD E,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.e = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x60] = { // LD IXH,B
            self.regs.iyh = self.regs.b
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x61] = { // LD IXH,C
            self.regs.iyh = self.regs.c
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x62] = { // LD IXH,D
            self.regs.iyh = self.regs.d
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x63] = { // LD IXH,E
            self.regs.iyh = self.regs.e
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x64] = { // LD IXH,IXH
            self.regs.iyh = self.regs.iyh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x65] = { // LD IXH,IXL
            self.regs.iyh = self.regs.iyl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x66] = { // LD H,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.h = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x67] = { // LD IXH,A
            self.regs.iyh = self.regs.a
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x68] = { // LD IXL,B
            self.regs.iyl = self.regs.b
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x69] = { // LD IXL,C
            self.regs.iyl = self.regs.c
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6A] = { // LD IXL,D
            self.regs.iyl = self.regs.d
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6B] = { // LD IXL,E
            self.regs.iyl = self.regs.e
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6C] = { // LD IXL,IXH
            self.regs.iyl = self.regs.iyh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6D] = { // LD IXL,IXL
            self.regs.iyl = self.regs.iyl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x6E] = { // LD L,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.l = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x6F] = { // LD IXL,A
            self.regs.iyl = self.regs.a
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x70] = { // LD (IY+0),B
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.b
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x71] = { // LD (IY+0),C
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.c
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x72] = { // LD (IY+0),D
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.d
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x73] = { // LD (IY+0),E
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.e
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x74] = { // LD (IY+0),H
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.h
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x75] = { // LD (IY+0),L
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.l
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x77] = { // LD (IY+0),A
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.pins.data_bus = self.regs.a
                    self.machine_cycle = .MemoryWrite
                }
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x7C] = { // LD A,IXH
            self.regs.a = self.regs.iyh
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7D] = { // LD A,IXL
            self.regs.a = self.regs.iyl
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x7E] = { // LD A,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x84] = { // ADD A,IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyh, ulaOp: .Add, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x85] = { // ADD A,IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyl, ulaOp: .Add, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x86] = { // ADD A,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Add, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x8C] = { // ADC A,IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyh, ulaOp: .Adc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x8D] = { // ADC A,IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyl, ulaOp: .Adc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x8E] = { // ADC A,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Adc, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x94] = { // SUB A,IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyh, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x95] = { // SUB A,IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyl, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x96] = { // SUB A,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0x9C] = { // SBC A,IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyh, ulaOp: .Sbc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x9D] = { // SBC A,IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyl, ulaOp: .Sbc, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0x9E] = { // SBC A,(IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sbc, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xA4] = { // AND IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyh, ulaOp: .And, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xA5] = { // AND IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyl, ulaOp: .And, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xA6] = { // AND (IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .And, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xAC] = { // XOR IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyh, ulaOp: .Xor, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xAD] = { // XOR IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyl, ulaOp: .Xor, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xAE] = { // XOR (IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Xor, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xB4] = { // OR IXH
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyh, ulaOp: .Or, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xB5] = { // OR IXL
            self.regs.a = self.ulaCall(self.regs.a, self.regs.iyl, ulaOp: .Or, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xB6] = { // OR (IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.regs.a = self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Or, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xBC] = { // CP IXH
            self.ulaCall(self.regs.a, self.regs.iyh, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xBD] = { // CP IXL
            self.ulaCall(self.regs.a, self.regs.iyl, ulaOp: .Sub, ignoreCarry: false)
            self.id_opcode_table = prefix_NONE
        }
        opcodes[0xBE] = { // CP (IY+0)
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
                    self.pins.address_bus = self.addressFromPair(self.regs.iyh, self.regs.iyl)
                    self.pins.address_bus = UInt16(Int(self.pins.address_bus) + Int(self.control_reg.comp2))
                    self.machine_cycle = .MemoryRead
                }
            default:
                self.ulaCall(self.regs.a, self.pins.data_bus, ulaOp: .Sub, ignoreCarry: false)
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xCB] = {
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
                self.regs.ir_ = self.pins.data_bus
                fallthrough
            default:
                self.opcode_tables[prefix_FDCB][Int(self.regs.ir_)]()
            }
        }
        opcodes[0xE1] = { // POP IY
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.regs.sp += 1
                self.machine_cycle = .MemoryRead
            case 3:
                self.regs.iyl = self.pins.data_bus
                self.pins.address_bus = self.regs.sp
                self.regs.sp += 1
            default:
                self.regs.iyh = self.pins.data_bus
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE3] = { // EX (SP), IY
            switch self.m_cycle {
            case 2:
                self.pins.address_bus = self.regs.sp
                self.machine_cycle = .MemoryRead
            case 3:
                self.control_reg = self.pins.data_bus
                self.pins.data_bus = self.regs.iyl
                self.regs.iyl = self.control_reg
                self.machine_cycle = .MemoryWrite
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
                    self.pins.address_bus = self.regs.sp + 1
                    self.machine_cycle = .MemoryRead
                }
            case 5:
                self.control_reg = self.pins.data_bus
                self.pins.data_bus = self.regs.iyh
                self.regs.iyh = self.control_reg
                self.machine_cycle = .MemoryWrite
            default:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.machine_cycle = .OpcodeFetch
                    self.id_opcode_table = prefix_NONE
                }
            }
        }
        opcodes[0xE5] = { // PUSH IY
            switch self.m_cycle {
            case 2:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.regs.sp -= 1
                    self.pins.address_bus = self.regs.sp
                    self.pins.data_bus = self.regs.iyh
                    self.machine_cycle = .MemoryWrite
                }
            case 3:
                self.regs.sp -= 1
                self.pins.address_bus = self.regs.sp
                self.pins.data_bus = self.regs.iyl
            default:
                self.machine_cycle = .OpcodeFetch
                self.id_opcode_table = prefix_NONE
            }
        }
        opcodes[0xE9] = { // JP (IY)
            self.regs.pc = self.addressFromPair(self.regs.iyh, self.regs.iyl)
            self.id_opcode_table = prefix_NONE
        }
    }
}