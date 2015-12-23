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
                self.machine_cycle = .TimeWait
                if self.t_cycle == 4 {
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
        }
    }
}