//
//  cu.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 6/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

class ControlUnit {
    // MARK: Parameters
    
    let pins : Pins
    var regs : Registers!
    
    typealias OpcodeTable = [() -> Void]
    
    var opcode_tables : [OpcodeTable]!
    
    var id_opcode_table : Int
    
    var m_cycle : Int
    var t_cycle : Int
    
    var machine_cycle : MachineCycle
    
    var control_reg : UInt8! // backup register to store parameters between t_cycles of execution
    
    // MARK: Methods
    func isPrefixed() -> Bool {
        return (id_opcode_table != prefix_NONE) ? true : false
    }
    
    func addressFromPair(val_h: UInt8, _ val_l: UInt8) -> UInt16 {
        return UInt16(Int(Int(val_h) * 0x100) + Int(val_l))
    }
    func processOpcode(inout regs: Registers, _ t_cycle: Int, _ m_cycle: Int, inout _ machine_cycle: MachineCycle) {
        self.m_cycle = m_cycle
        self.t_cycle = t_cycle
        self.regs = regs
        self.machine_cycle = machine_cycle

        opcode_tables[id_opcode_table][Int(self.regs.ir)]()
        
        machine_cycle = self.machine_cycle
        regs = self.regs
    }
    
    func ulaCall16(operandA: UInt16, _ operandB: UInt16, ulaOp: UlaOp) -> UInt16 {
        let f_old = regs.f
        
        let result_l = ulaCall(operandA.low, operandB.low, ulaOp: ulaOp, ignoreCarry: false)
        
        var ulaOp_high = ulaOp
        
        switch ulaOp {
        case .Add: ulaOp_high = .Adc
        case .Sub: ulaOp_high = .Sbc
        default: break
        }
        
        let result_h = ulaCall(operandA.high, operandB.high, ulaOp: ulaOp_high, ignoreCarry: false)
        // bits S, Z and PV are not affected so restore from F backup
        self.regs.f.bit(S, newVal: f_old.bit(S))
        self.regs.f.bit(Z, newVal: f_old.bit(Z))
        self.regs.f.bit(PV, newVal: f_old.bit(PV))
        // N is reset
        self.regs.f.resetBit(N)
        
        
        return addressFromPair(result_h, result_l)
    }
    
    func ulaCall(operandA: UInt8, _ operandB: UInt8, ulaOp: UlaOp, ignoreCarry: Bool) -> UInt8 {
        /*
        Bit      0 1 2 3 4  5  6 7
        ￼￼Position S Z X H X P/V N C
        */
        
        var result: UInt8?
        var old_carry: UInt8 = 0
        
        switch ulaOp {
        case .Adc:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Add:
            result = operandA &+ operandB &+ old_carry
            
            if result!.low < operandA.low {regs.f.setBit(H)} else {regs.f.resetBit(H)} // H (Half Carry)
            regs.f.resetBit(N) // N (Add)
            regs.f.bit(PV, newVal: checkOverflow(operandA, operandB, result: result!, ulaOp: ulaOp))
            regs.f.bit(S, newVal: result!.bit(7))
            
            if !ignoreCarry && operandB > 0 {
                if result! <= operandA {regs.f.setBit(C)} else {regs.f.resetBit(C)} // C (Carry)
            }
            
            if result! == 0 {regs.f.setBit(Z)} else {regs.f.resetBit(Z)} // Z (Zero)
            
        case .Sbc:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Sub:
            result = operandA &- operandB &- old_carry
            
            if result!.low > operandA.low {regs.f.setBit(H)} else {regs.f.resetBit(H)} // H (Half Carry)
            regs.f.setBit(N) // N (Substract)
            regs.f.bit(PV, newVal: checkOverflow(operandA, operandB, result: result!, ulaOp: ulaOp))
            regs.f.bit(S, newVal: result!.bit(7))
            
            if !ignoreCarry {
                if result! > operandA {regs.f.setBit(C)} else {regs.f.resetBit(C)} // C (Carry)
            }
            if result! == 0 {regs.f.setBit(Z)} else {regs.f.resetBit(Z)} // Z (Zero)
            
        case .Rl:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Rlc:
            regs.f.bit(C, newVal: operandA.bit(7)) // sign bit is copied to the carry flag
            result = operandA << 1
            if ulaOp == .Rl {
                result!.bit(0, newVal: Int(old_carry)) // old carry is copied to the bit 0
            } else {
                result!.bit(0, newVal: regs.f.bit(C)) // new carry is copied to the bit 0
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result!))
            
        case .Rr:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Rrc:
            regs.f.bit(C, newVal: operandA.bit(0)) // least significant bit is copied to the carry flag
            result = operandA >> 1
            if ulaOp == .Rr {
                result!.bit(7, newVal: Int(old_carry)) // old carry is copied to the bit 7
            } else {
                result!.bit(7, newVal: regs.f.bit(C)) // new carry is copied to the bit 7
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result!))
        
        case .And:
            fallthrough
        case .Or:
            fallthrough
        case .Xor:
            switch ulaOp {
            case .And:
                result = operandA & operandB
                regs.f.setBit(H)
            case .Or:
                result = operandA | operandB
                regs.f.resetBit(H)
            case .Xor:
                result = operandA ^ operandB
                regs.f.resetBit(H)
            default:
                break
            }
            
            regs.f.bit(S, newVal: result!.bit(7))
            if result == 0 { regs.f.setBit(Z) } else { regs.f.resetBit(Z) }
            regs.f.bit(PV, newVal: checkParity(result!))
            regs.f.resetBit(N)
            regs.f.resetBit(C)
            
        default:
            break
        }
        
        return result!
    }
    
    func checkOverflow(opA: UInt8, _ opB: UInt8, result: UInt8, ulaOp: UlaOp) -> Int {
        // will return true if an overflow has occurred, false if no overflow
        switch ulaOp {
        case .Add:
            fallthrough
        case .Adc:
            if (opA.bit(7) == opB.bit(7)) && (result.bit(7) != opA.bit(7)) {
                // same sign in both operands and different sign in result
                return 1
            }
        case .Sub:
            fallthrough
        case .Sbc:
            if (opA.bit(7) != opB.bit(7)) && (result.bit(7) == opB.bit(7)) {
                // different sign in both operands and same sign in result
                return 1
            }
        default:
            break
        }
        
        return 0
    }
    
    func checkParity(data: UInt8) -> Int {
        return (data.parity == 0) ? 1 : 0 // 1 -> Even parity, 0 -> Odd parity
    }

    // MARK: Initialization
    init(pins: Pins) {
        m_cycle = 0
        t_cycle = 0
        machine_cycle = .OpcodeFetch
        self.pins = pins
        id_opcode_table = prefix_NONE
        
        opcode_tables = [OpcodeTable](count: 7, repeatedValue: OpcodeTable(count: 0x100, repeatedValue: {}))
        
        initOpcodeTableNONE(&opcode_tables[prefix_NONE])
        initOpcodeTableDD(&opcode_tables[prefix_DD])
    }
    
}