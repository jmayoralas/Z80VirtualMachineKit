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
        
        opcodes[0x07] = { // RRC A
            self.regs.a = self.ulaCall(self.regs.a, 1, ulaOp: .Rrc, ignoreCarry: false)
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
    }
}
