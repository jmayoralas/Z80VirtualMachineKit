//
//  ControlUnit_opcodes_ed.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 23/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

// t_cycle = 8 ((ED)4, (Op)4)
extension Z80 {
    func initOpcodeTableED(_ opcodes: inout OpcodeTable) {
        opcodes[0x40] = { // IN B,(C)
            self.t_cycle += 4
            let data = self.ioBus.read(self.regs.bc)
            if data.bit(7) == 1 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if data == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(PV, newVal: self.checkParity(data))
            self.regs.f.resetBit(N)
            
            self.regs.b = data
        }
        opcodes[0x41] = { // OUT (C),B
            self.t_cycle += 4
            self.ioBus.write(self.regs.bc, value: self.regs.b)
        }
        opcodes[0x42] = { // SBC HL,BC
            self.t_cycle += 7
            self.regs.hl = self.aluCall16(self.regs.hl, self.regs.bc, ulaOp: .sbc)
        }
        opcodes[0x43] = { // LD (&0000),BC
            self.t_cycle += 12
            let address = self.addressFromPair(self.dataBus.read(self.regs.pc &+ 1), self.dataBus.read(self.regs.pc))
            self.regs.pc = self.regs.pc &+ 2
            self.dataBus.write(address, value: self.regs.c)
            self.dataBus.write(address &+ 1, value: self.regs.b)
        }
        opcodes[0x44] = { // NEG
            self.regs.a = self.aluCall(0, self.regs.a, ulaOp: .sub, ignoreCarry: false)
        }
        opcodes[0x45] = { // RETN
            self.ret()
            self.regs.IFF1 = self.regs.IFF2
        }
        opcodes[0x46] = { // IM 0
            self.regs.int_mode = 0
        }
        opcodes[0x47] = { // LD I,A
            self.t_cycle += 1
            self.regs.i = self.regs.a
        }
        opcodes[0x48] = { // IN C,(C)
            self.t_cycle += 4
            let data = self.ioBus.read(self.regs.bc)
            if data.bit(7) == 1 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if data == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(PV, newVal: self.checkParity(data))
            self.regs.f.resetBit(N)
            
            self.regs.c = data
        }
        opcodes[0x49] = { // OUT (C),C
            self.t_cycle += 4
            self.ioBus.write(self.regs.bc, value: self.regs.c)
        }
        opcodes[0x4A] = { // ADC HL,BC
            self.t_cycle += 7
            self.regs.hl = self.aluCall16(self.regs.hl, self.regs.bc, ulaOp: .adc)
        }
        opcodes[0x4B] = { // LD BC,(&0000)
            self.t_cycle += 12
            let address = self.addressFromPair(self.dataBus.read(self.regs.pc &+ 1), self.dataBus.read(self.regs.pc))
            self.regs.pc = self.regs.pc &+ 2
            self.regs.c = self.dataBus.read(address)
            self.regs.b = self.dataBus.read(address &+ 1)
        }
        opcodes[0x4C] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x4D] = { // RETI #TO-DO: signal an I/O device that the interrupt routine is completed
            self.ret()
        }
        opcodes[0x4E] = { // IM 0
            self.opcode_tables[self.id_opcode_table][0x46]()
        }
        opcodes[0x4F] = { // LD R,A
            self.t_cycle += 1
            self.regs.r = self.regs.a
        }
        opcodes[0x50] = { // IN D,(C)
            self.t_cycle += 4
            let data = self.ioBus.read(self.regs.bc)
            if data.bit(7) == 1 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if data == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(PV, newVal: self.checkParity(data))
            self.regs.f.resetBit(N)
            
            self.regs.d = data
        }
        opcodes[0x51] = { // OUT (C),D
            self.t_cycle += 4
            self.ioBus.write(self.regs.bc, value: self.regs.d)
        }
        opcodes[0x52] = { // SBC HL,DE
            self.t_cycle += 7
            self.regs.hl = self.aluCall16(self.regs.hl, self.regs.de, ulaOp: .sbc)
        }
        opcodes[0x53] = { // LD (&0000),DE
            self.t_cycle += 12
            let address = self.addressFromPair(self.dataBus.read(self.regs.pc &+ 1), self.dataBus.read(self.regs.pc))
            self.regs.pc = self.regs.pc &+ 2
            self.dataBus.write(address, value: self.regs.e)
            self.dataBus.write(address &+ 1, value: self.regs.d)
        }
        opcodes[0x54] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x55] = { // RETN
            self.opcode_tables[self.id_opcode_table][0x45]()
        }
        opcodes[0x56] = { // IM 1
            self.regs.int_mode = 1
        }
        opcodes[0x57] = { // LD A,I
            self.t_cycle += 1
            self.regs.a = self.regs.i
            if self.regs.i.bit(7) > 0 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if self.regs.i == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.resetBit(H)
            if self.regs.IFF2 {
                self.regs.f.setBit(PV)
            } else {
                self.regs.f.resetBit(PV)
            }
            self.regs.f.resetBit(N)
            
        }
        opcodes[0x58] = { // IN E,(C)
            self.t_cycle += 4
            let data = self.ioBus.read(self.regs.bc)
            if data.bit(7) == 1 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if data == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(PV, newVal: self.checkParity(data))
            self.regs.f.resetBit(N)
            
            self.regs.e = data
        }
        opcodes[0x59] = { // OUT (C),E
            self.t_cycle += 4
            self.ioBus.write(self.regs.bc, value: self.regs.e)
        }
        opcodes[0x5A] = { // ADC HL,DE
            self.t_cycle += 7
            self.regs.hl = self.aluCall16(self.regs.hl, self.regs.de, ulaOp: .adc)
        }
        opcodes[0x5B] = { // LD DE,(&0000)
            self.t_cycle += 12
            let address = self.addressFromPair(self.dataBus.read(self.regs.pc &+ 1), self.dataBus.read(self.regs.pc))
            self.regs.pc = self.regs.pc &+ 2
            self.regs.e = self.dataBus.read(address)
            self.regs.d = self.dataBus.read(address &+ 1)
        }
        opcodes[0x5C] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x5D] = { // RETI
            self.opcode_tables[self.id_opcode_table][0x4D]()
        }
        opcodes[0x5E] = { // IM 2
            self.regs.int_mode = 2
        }
        opcodes[0x5F] = { // LD A,R
            self.t_cycle += 1
            self.regs.a = self.regs.r
            if self.regs.r.bit(7) > 0 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if self.regs.r == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.resetBit(H)
            if self.regs.IFF2 {
                self.regs.f.setBit(PV)
            } else {
                self.regs.f.resetBit(PV)
            }
            self.regs.f.resetBit(N)
        }
        opcodes[0x60] = { // IN H,(C)
            self.t_cycle += 4
            let data = self.ioBus.read(self.regs.bc)
            if data.bit(7) == 1 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if data == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(PV, newVal: self.checkParity(data))
            self.regs.f.resetBit(N)
            
            self.regs.h = data
        }
        opcodes[0x61] = { // OUT (C),H
            self.t_cycle += 4
            self.ioBus.write(self.regs.bc, value: self.regs.h)
        }
        opcodes[0x62] = { // SBC HL,HL
            self.t_cycle += 7
            self.regs.hl = self.aluCall16(self.regs.hl, self.regs.hl, ulaOp: .sbc)
        }
        opcodes[0x63] = { // LD (&0000),HL
            self.t_cycle += 12
            let address = self.addressFromPair(self.dataBus.read(self.regs.pc &+ 1), self.dataBus.read(self.regs.pc))
            self.regs.pc = self.regs.pc &+ 2
            self.dataBus.write(address, value: self.regs.l)
            self.dataBus.write(address &+ 1, value: self.regs.h)
        }
        opcodes[0x64] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x65] = { // RETN
            self.opcode_tables[self.id_opcode_table][0x45]()
        }
        opcodes[0x66] = { // IM 0
            self.opcode_tables[self.id_opcode_table][0x46]()
        }
        opcodes[0x67] = { // RRD
            self.t_cycle += 10
            var data = self.dataBus.read(self.regs.hl)
            let a = self.regs.a
            self.regs.a = a.high + data.low
            data = a.low * 0x10 + data.high / 0x10
            self.regs.f.bit(S, newVal: self.regs.a.bit(7))
            if self.regs.a == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(3, newVal: self.regs.a.bit(3))
            self.regs.f.bit(5, newVal: self.regs.a.bit(5))
            
            self.regs.f.resetBit(H)
            self.regs.f.bit(PV, newVal: self.checkParity(self.regs.a))
            self.regs.f.resetBit(N)
            self.dataBus.write(self.regs.hl, value: data)
        }
        opcodes[0x68] = { // IN L,(C)
            self.t_cycle += 4
            let data = self.ioBus.read(self.regs.bc)
            if data.bit(7) == 1 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if data == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(PV, newVal: self.checkParity(data))
            self.regs.f.resetBit(N)
            
            self.regs.l = data
        }
        opcodes[0x69] = { // OUT (C),L
            self.t_cycle += 4
            self.ioBus.write(self.regs.bc, value: self.regs.l)
        }
        opcodes[0x6A] = { // ADC HL,HL
            self.t_cycle += 7
            self.regs.hl = self.aluCall16(self.regs.hl, self.regs.hl, ulaOp: .adc)
        }
        opcodes[0x6B] = { // LD HL,(&0000)
            self.t_cycle += 12
            let address = self.addressFromPair(self.dataBus.read(self.regs.pc &+ 1), self.dataBus.read(self.regs.pc))
            self.regs.pc = self.regs.pc &+ 2
            self.regs.l = self.dataBus.read(address)
            self.regs.h = self.dataBus.read(address &+ 1)
        }
        opcodes[0x6C] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x6D] = { // RETI
            self.opcode_tables[self.id_opcode_table][0x4D]()
        }
        opcodes[0x6E] = { // IM 0
            self.opcode_tables[self.id_opcode_table][0x46]()
        }
        opcodes[0x6F] = { // RLD
            self.t_cycle += 10
            var data = self.dataBus.read(self.regs.hl)
            let a = self.regs.a
            self.regs.a = a.high + data.high / 0x10
            data = data.low * 0x10 + a.low
            self.regs.f.bit(S, newVal: self.regs.a.bit(7))
            if self.regs.a == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(3, newVal: self.regs.a.bit(3))
            self.regs.f.bit(5, newVal: self.regs.a.bit(5))
            
            self.regs.f.resetBit(H)
            self.regs.f.bit(PV, newVal: self.checkParity(self.regs.a))
            self.regs.f.resetBit(N)
            
            self.dataBus.write(self.regs.hl, value: data)
        }
        opcodes[0x70] = { // IN _,(C)
            self.t_cycle += 4
            let data = self.ioBus.read(self.regs.bc)
            if data.bit(7) == 1 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if data == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(PV, newVal: self.checkParity(data))
            self.regs.f.resetBit(N)
        }
        opcodes[0x71] = { // OUT (C),_
            self.t_cycle += 4
            self.ioBus.write(self.regs.bc, value: 0)
        }
        opcodes[0x72] = { // SBC HL,SP
            self.t_cycle += 7
            self.regs.hl = self.aluCall16(self.regs.hl, self.regs.sp, ulaOp: .sbc)
        }
        opcodes[0x73] = { // LD (&0000),SP
            self.t_cycle += 12
            let address = self.addressFromPair(self.dataBus.read(self.regs.pc &+ 1), self.dataBus.read(self.regs.pc))
            self.regs.pc = self.regs.pc &+ 2
            self.dataBus.write(address, value: self.regs.sp.low)
            self.dataBus.write(address &+ 1, value: self.regs.sp.high)
        }
        opcodes[0x74] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x75] = { // RETN
            self.opcode_tables[self.id_opcode_table][0x45]()
        }
        opcodes[0x76] = { // IM 1
            self.opcode_tables[self.id_opcode_table][0x56]()
        }
        opcodes[0x77] = { // NOP
        
        }
        opcodes[0x78] = { // IN A,(C)
            self.t_cycle += 4
            let data = self.ioBus.read(self.regs.bc)
            if data.bit(7) == 1 {
                self.regs.f.setBit(S)
            } else {
                self.regs.f.resetBit(S)
            }
            if data == 0 {
                self.regs.f.setBit(Z)
            } else {
                self.regs.f.resetBit(Z)
            }
            self.regs.f.bit(PV, newVal: self.checkParity(data))
            self.regs.f.resetBit(N)
            
            self.regs.a = data
        }
        opcodes[0x79] = { // OUT (C),A
            self.t_cycle += 4
            self.ioBus.write(self.regs.bc, value: self.regs.a)
        }
        opcodes[0x7A] = { // ADC HL,SP
            self.t_cycle += 7
            self.regs.hl = self.aluCall16(self.regs.hl, self.regs.sp, ulaOp: .adc)
        }
        opcodes[0x7B] = { // LD SP,(&0000)
            self.t_cycle += 12
            let address = self.addressFromPair(self.dataBus.read(self.regs.pc &+ 1), self.dataBus.read(self.regs.pc))
            self.regs.pc = self.regs.pc &+ 2
            self.regs.sp = self.addressFromPair(self.dataBus.read(address &+ 1), self.dataBus.read(address))
        }
        opcodes[0x7C] = { // NEG
            self.opcode_tables[self.id_opcode_table][0x44]()
        }
        opcodes[0x7D] = { // RETI
            self.opcode_tables[self.id_opcode_table][0x4D]()
        }
        opcodes[0x7E] = { // IM 2
            self.opcode_tables[self.id_opcode_table][0x5E]()
        }
        opcodes[0x7F] = { // RLD
            self.id_opcode_table = table_NONE
        }
        opcodes[0xA0] = { // LDI
            self.t_cycle += 8
            
            var data = self.dataBus.read(self.regs.hl)
            self.dataBus.write(self.regs.de, value: data)
            
            let f_backup = self.regs.f
            self.regs.de = self.aluCall16(self.regs.de, 1, ulaOp: .add)
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .add)
            self.regs.bc = self.aluCall16(self.regs.bc, 1, ulaOp: .sub)
            self.regs.f = f_backup
            self.regs.f.resetBit(H)
            self.regs.f.resetBit(N)
            if self.regs.bc != 0 {
                self.regs.f.setBit(PV)
            } else {
                self.regs.f.resetBit(PV)
            }
            
            data = data &+ self.regs.a
            self.regs.f.bit(3, newVal: data.bit(3))
            self.regs.f.bit(5, newVal: data.bit(1))
        }
        opcodes[0xA1] = { // CPI
            self.t_cycle += 8
            var data = self.aluCall(self.regs.a, self.dataBus.read(self.regs.hl), ulaOp: .cp, ignoreCarry: true)
            
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .add)
            self.regs.bc = self.aluCall16(self.regs.bc, 1, ulaOp: .sub)
            self.regs.f = f_backup
            if self.regs.bc != 0 {
                self.regs.f.setBit(PV)
            } else {
                self.regs.f.resetBit(PV)
            }
            
            data = data &- UInt8(self.regs.f.bit(H))
            self.regs.f.bit(3, newVal: data.bit(3))
            self.regs.f.bit(5, newVal: data.bit(1))
        }
        opcodes[0xA2] = { // INI
            self.t_cycle += 8
            
            let data = self.ioBus.read(self.regs.bc)
            self.dataBus.write(self.regs.hl, value: data)
            
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .add)
            self.regs.f = f_backup
            self.regs.b = self.aluCall(self.regs.b, 1, ulaOp: .sub, ignoreCarry: true)
        }
        opcodes[0xA3] = { // OUTI
            self.t_cycle += 8
            
            let data = self.dataBus.read(self.regs.hl)
            self.regs.b = self.aluCall(self.regs.b, 1, ulaOp: .sub, ignoreCarry: true)
            self.ioBus.write(self.regs.bc, value: data)
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .add)
            self.regs.f = f_backup
        }
        opcodes[0xA8] = { // LDD
            self.t_cycle += 8
            
            var data = self.dataBus.read(self.regs.hl)
            self.dataBus.write(self.regs.de, value: data)
            
            let f_backup = self.regs.f
            self.regs.de = self.aluCall16(self.regs.de, 1, ulaOp: .sub)
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .sub)
            self.regs.bc = self.aluCall16(self.regs.bc, 1, ulaOp: .sub)
            self.regs.f = f_backup
            self.regs.f.resetBit(H)
            self.regs.f.resetBit(N)
            if self.regs.bc != 0 {
                self.regs.f.setBit(PV)
            } else {
                self.regs.f.resetBit(PV)
            }
            
            data = data &+ self.regs.a
            self.regs.f.bit(3, newVal: data.bit(3))
            self.regs.f.bit(5, newVal: data.bit(1))
        }
        opcodes[0xA9] = { // CPD
            self.t_cycle += 8
            var data = self.aluCall(self.regs.a, self.dataBus.read(self.regs.hl), ulaOp: .cp, ignoreCarry: true)
            
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .sub)
            self.regs.bc = self.aluCall16(self.regs.bc, 1, ulaOp: .sub)
            self.regs.f = f_backup
            if self.regs.bc != 0 {
                self.regs.f.setBit(PV)
            } else {
                self.regs.f.resetBit(PV)
            }
            
            data = data &- UInt8(self.regs.f.bit(H))
            self.regs.f.bit(3, newVal: data.bit(3))
            self.regs.f.bit(5, newVal: data.bit(1))
        }
        opcodes[0xAA] = { // IND
            self.t_cycle += 8
            self.dataBus.write(self.regs.hl, value: self.ioBus.read(self.regs.bc))
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .sub)
            self.regs.f = f_backup
            self.regs.b = self.aluCall(self.regs.b, 1, ulaOp: .sub, ignoreCarry: true)
        }
        opcodes[0xAB] = { // OUTD
            self.t_cycle += 8
            self.regs.b = self.aluCall(self.regs.b, 1, ulaOp: .sub, ignoreCarry: true)
            self.ioBus.write(self.regs.bc, value: self.dataBus.read(self.regs.hl))
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .sub)
            self.regs.f = f_backup
        }
        opcodes[0xB0] = { // LDIR
            self.t_cycle += 8
            var data = self.dataBus.read(self.regs.hl)
            self.dataBus.write(self.regs.de, value: data)
            let f_backup = self.regs.f
            self.regs.de = self.aluCall16(self.regs.de, 1, ulaOp: .add)
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .add)
            self.regs.bc = self.aluCall16(self.regs.bc, 1, ulaOp: .sub)
            self.regs.f = f_backup
            self.regs.f.resetBit(H)
            self.regs.f.resetBit(N)
            self.regs.f.resetBit(PV)
            if self.regs.bc != 0 {
                self.t_cycle += 5
                self.regs.pc = self.regs.pc &- 2
                self.regs.f.setBit(PV)
            }
            
            data = data &+ self.regs.a
            self.regs.f.bit(3, newVal: data.bit(3))
            self.regs.f.bit(5, newVal: data.bit(1))
        }
        opcodes[0xB1] = { // CPIR
            self.t_cycle += 8
            var data = self.aluCall(self.regs.a, self.dataBus.read(self.regs.hl), ulaOp: .cp, ignoreCarry: true)
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .add)
            self.regs.bc = self.aluCall16(self.regs.bc, 1, ulaOp: .sub)
            self.regs.f = f_backup
            self.regs.f.resetBit(PV)
            if self.regs.bc != 0 {
                self.regs.f.setBit(PV)
                if self.regs.f.bit(Z) == 0 {
                    self.t_cycle += 5
                    self.regs.pc = self.regs.pc &- 2
                }
            }
            
            data = data &- UInt8(self.regs.f.bit(H))
            self.regs.f.bit(3, newVal: data.bit(3))
            self.regs.f.bit(5, newVal: data.bit(1))
        }
        opcodes[0xB2] = { // INIR
            self.t_cycle += 8
            self.dataBus.write(self.regs.hl, value: self.ioBus.read(self.regs.bc))
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .add)
            self.regs.f = f_backup
            self.regs.b = self.aluCall(self.regs.b, 1, ulaOp: .sub, ignoreCarry: true)
            if self.regs.b != 0 {
                self.t_cycle += 5
                self.regs.pc = self.regs.pc &- 2
                self.regs.f.setBit(PV)
            }
        }
        opcodes[0xB3] = { // OTIR
            self.t_cycle += 8
            self.regs.b = self.aluCall(self.regs.b, 1, ulaOp: .sub, ignoreCarry: true)
            self.ioBus.write(self.regs.bc, value: self.dataBus.read(self.regs.hl))
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .add)
            self.regs.f = f_backup
            if self.regs.b != 0 {
                self.t_cycle += 5
                self.regs.pc = self.regs.pc &- 2
                self.regs.f.setBit(PV)
            }
        }
        opcodes[0xB8] = { // LDDR
            self.t_cycle += 8
            
            var data = self.dataBus.read(self.regs.hl)
            self.dataBus.write(self.regs.de, value: data)
            let f_backup = self.regs.f
            self.regs.de = self.aluCall16(self.regs.de, 1, ulaOp: .sub)
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .sub)
            self.regs.bc = self.aluCall16(self.regs.bc, 1, ulaOp: .sub)
            self.regs.f = f_backup
            self.regs.f.resetBit(H)
            self.regs.f.resetBit(N)
            self.regs.f.resetBit(PV)
            if self.regs.bc != 0 {
                self.t_cycle += 5
                self.regs.pc = self.regs.pc &- 2
                self.regs.f.setBit(PV)
            }
        
            data = data &+ self.regs.a
            self.regs.f.bit(3, newVal: data.bit(3))
            self.regs.f.bit(5, newVal: data.bit(1))
        }
        opcodes[0xB9] = { // CPDR
            self.t_cycle += 8
            
            var data = self.aluCall(self.regs.a, self.dataBus.read(self.regs.hl), ulaOp: .cp, ignoreCarry: true)
            
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .sub)
            self.regs.bc = self.aluCall16(self.regs.bc, 1, ulaOp: .sub)
            self.regs.f = f_backup
            
            self.regs.f.resetBit(PV)
            
            if self.regs.bc != 0 {
                self.regs.f.setBit(PV)
                if self.regs.f.bit(Z) == 0 {
                    self.t_cycle += 5
                    self.regs.pc = self.regs.pc &- 2
                }
            }
            
            data = data &- UInt8(self.regs.f.bit(H))
            self.regs.f.bit(3, newVal: data.bit(3))
            self.regs.f.bit(5, newVal: data.bit(1))
        }
        opcodes[0xBA] = { // INDR
            self.t_cycle += 8
            self.dataBus.write(self.regs.hl, value: self.ioBus.read(self.regs.bc))
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .sub)
            self.regs.f = f_backup
            self.regs.b = self.aluCall(self.regs.b, 1, ulaOp: .sub, ignoreCarry: true)
            if self.regs.b != 0 {
                self.t_cycle += 5
                self.regs.pc = self.regs.pc &- 2
                self.regs.f.setBit(PV)
            }
        }
        opcodes[0xBB] = { // OTDR
            self.t_cycle += 8
            self.regs.b = self.aluCall(self.regs.b, 1, ulaOp: .sub, ignoreCarry: true)
            self.ioBus.write(self.regs.bc, value: self.dataBus.read(self.regs.hl))
            let f_backup = self.regs.f
            self.regs.hl = self.aluCall16(self.regs.hl, 1, ulaOp: .sub)
            self.regs.f = f_backup
            if self.regs.b != 0 {
                self.t_cycle += 5
                self.regs.pc = self.regs.pc &- 2
                self.regs.f.setBit(PV)
            }
        }
    }
}
