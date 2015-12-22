//
//  ControlUnit_opcodes_ddcb.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 22/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension ControlUnit {
    func initOpcodeTableDDCB(inout opcodes: OpcodeTable) {
        opcodes[0x00] = { // rlc (ix+0) -> b
            switch self.m_cycle {
            case 4:
                self.machine_cycle = .TimeWait
                if self.t_cycle == 5 {
                    self.pins.address_bus = self.addressFromPair(self.regs.ixh, self.regs.ixl)
                    self.pins.address_bus = UInt16(Int16(self.pins.address_bus) + Int16(self.control_reg.comp2))
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
    }
}