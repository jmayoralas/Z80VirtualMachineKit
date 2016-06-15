//
//  cu.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 6/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

extension Z80 {
    // MARK: Methods
    func isPrefixed() -> Bool {
        return (id_opcode_table != table_NONE) ? true : false
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
        if ulaOp == .Add {
            // bits S, Z and PV are not affected so restore from F backup
            self.regs.f.bit(S, newVal: f_old.bit(S))
            self.regs.f.bit(Z, newVal: f_old.bit(Z))
            self.regs.f.bit(PV, newVal: f_old.bit(PV))
        }
        
        return addressFromPair(result_h, result_l)
    }
    
    func ulaCall(operandA: UInt8, _ operandB: UInt8, ulaOp: UlaOp, ignoreCarry: Bool) -> UInt8 {
        /*
        Bit      0 1 2 3 4  5  6 7
        ￼￼Position S Z X H X P/V N C
        */
        
        var result: UInt8 = 0
        var old_carry: UInt8 = 0
        
        switch ulaOp {
        case .Adc:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Add:
            result = operandA &+ operandB &+ old_carry

            if (UInt8(operandA.low &+ operandB.low &+ old_carry) & 0xF0 > 0) {
                regs.f.setBit(H)
            } else {
                regs.f.resetBit(H)
            }
            
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkOverflow(operandA, operandB, result: result, ulaOp: ulaOp))
            
            if !ignoreCarry {
                if (result < operandA) || (result == operandA && operandB > 0) {
                    regs.f.setBit(C)
                } else {
                    regs.f.resetBit(C)
                } 
            }
            
        case .Sbc:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Sub:
            result = UInt8(operandA &- operandB &- old_carry)
            
            // H (Half Carry)
            if (UInt8(operandA.low &- operandB.low &- old_carry) & 0xF0 > 0) {
                regs.f.setBit(H)
            } else {
                regs.f.resetBit(H)
            }
            
            regs.f.setBit(N) // N (Substract)
            regs.f.bit(PV, newVal: checkOverflow(operandA, operandB, result: result, ulaOp: ulaOp))
            
            if !ignoreCarry {
                if (result > operandA) || (result == operandA && operandB > 0) {
                    regs.f.setBit(C)
                } else {
                    regs.f.resetBit(C)
                }
            }
            
        case .Rl:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Rlc:
            regs.f.bit(C, newVal: operandA.bit(7)) // sign bit is copied to the carry flag
            result = operandA << 1
            if ulaOp == .Rl {
                result.bit(0, newVal: Int(old_carry)) // old carry is copied to the bit 0
            } else {
                result.bit(0, newVal: regs.f.bit(C)) // new carry is copied to the bit 0
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
            
        case .Rr:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .Rrc:
            regs.f.bit(C, newVal: operandA.bit(0)) // least significant bit is copied to the carry flag
            result = operandA >> 1
            if ulaOp == .Rr {
                result.bit(7, newVal: Int(old_carry)) // old carry is copied to the bit 7
            } else {
                result.bit(7, newVal: regs.f.bit(C)) // new carry is copied to the bit 7
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
        
        case .Sls:
            fallthrough
        case .Sla:
            regs.f.bit(C, newVal: operandA.bit(7)) // sign bit is copied to the carry flag
            result = operandA << 1
            if ulaOp == .Sls {
                result.bit(0, newVal: 1)
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
            
        case .Sra:
            regs.f.bit(C, newVal: operandA.bit(0)) // bit 0 is copied to the carry flag
            let sign_bit = operandA.bit(7)
            result = operandA >> 1
            result.bit(7, newVal: sign_bit) // sign bit is restored
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
        
        case .Srl:
            regs.f.bit(C, newVal: operandA.bit(0)) // bit 0 is copied to the carry flag
            result = operandA >> 1
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
            
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
            
            regs.f.bit(PV, newVal: checkParity(result))
            regs.f.resetBit(N)
            regs.f.resetBit(C)
            
        case .Bit:
            result = operandA
            if operandA.bit(Int(operandB)) == 0 {
                regs.f.setBit(Z)
                regs.f.setBit(PV)
            } else {
                regs.f.resetBit(Z)
                regs.f.resetBit(PV)
                if operandB == 7 {
                    regs.f.setBit(S)
                }
            }
            regs.f.setBit(H)
            regs.f.resetBit(N)
            
        default:
            break
        }
        
        if ulaOp != .Bit {
            regs.f.bit(S, newVal: result.bit(7))
            if result == 0 {regs.f.setBit(Z)} else {regs.f.resetBit(Z)} // Z (Zero)
        }
        
        return result
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

    func rst(address: UInt16) {
        t_cycle += 7
        dataBus.write(regs.sp - 1, value: regs.pc.high)
        dataBus.write(regs.sp - 2, value: regs.pc.low)
        regs.sp = regs.sp &- 2
        regs.pc = address
        irq_kind = nil
    }
    
    func mode2SoftIrq() {
        // FIX-ME: must implement mode2 irq
    }
}
