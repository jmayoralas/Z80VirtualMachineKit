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
            }
        }
        opcodes[0x24] = { // INC IXH
            self.regs.ixh = self.ulaCall(self.regs.ixh, 1, ulaOp: .Add, ignoreCarry: true)
        }
        opcodes[0x25] = { // DEC IXH
            self.regs.ixh = self.ulaCall(self.regs.ixh, 1, ulaOp: .Sub, ignoreCarry: true)
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
            }
        }
        opcodes[0x2B] = { // DEC IX
            self.machine_cycle = .TimeWait
            
            if self.t_cycle == 6 {
                self.regs.ixl = self.regs.ixl &- 1
                self.regs.ixh = self.regs.ixl == 0xFF ? self.regs.ixh &- 1 : self.regs.ixh
                self.machine_cycle = .OpcodeFetch
            }
        }
        opcodes[0x2C] = { // INC IXL
            self.regs.ixl = self.ulaCall(self.regs.ixl, 1, ulaOp: .Add, ignoreCarry: true)
        }
        opcodes[0x2D] = { // DEC IXL
            self.regs.ixl = self.ulaCall(self.regs.ixl, 1, ulaOp: .Sub, ignoreCarry: true)
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
            }
        }
    }
}