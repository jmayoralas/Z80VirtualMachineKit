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
    
    func aluCall16(_ operandA: UInt16, _ operandB: UInt16, ulaOp: UlaOp) -> UInt16 {
        let f_old = regs.f
        
        let result_l = aluCall(operandA.low, operandB.low, ulaOp: ulaOp, ignoreCarry: false)
        
        var ulaOp_high = ulaOp
        
        switch ulaOp {
        case .add: ulaOp_high = .adc
        case .sub: ulaOp_high = .sbc
        default: break
        }
        
        let result_h = aluCall(operandA.high, operandB.high, ulaOp: ulaOp_high, ignoreCarry: false)
        
        if result_h == 0 && result_l == 0 {
            self.regs.f.setBit(Z)
        } else {
            self.regs.f.resetBit(Z)
        }
        
        if ulaOp == .add {
            // bits S, Z and PV are not affected so restore from F backup
            self.regs.f.bit(S, newVal: f_old.bit(S))
            self.regs.f.bit(Z, newVal: f_old.bit(Z))
            self.regs.f.bit(PV, newVal: f_old.bit(PV))
        }
        
        return addressFromPair(result_h, result_l)
    }
    
    func aluCall(_ operandA: UInt8, _ operandB: UInt8, ulaOp: UlaOp, ignoreCarry: Bool) -> UInt8 {
        /*
        Bit      0 1 2 3 4  5  6 7
        ￼￼Position S Z X H X P/V N C
        */
        
        var result: UInt8 = 0
        var old_carry: UInt8 = 0
        
        switch ulaOp {
        case .adc:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .add:
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
            
        case .sbc:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .sub:
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
            
        case .rl:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .rlc:
            regs.f.bit(C, newVal: operandA.bit(7)) // sign bit is copied to the carry flag
            result = operandA << 1
            if ulaOp == .rl {
                result.bit(0, newVal: Int(old_carry)) // old carry is copied to the bit 0
            } else {
                result.bit(0, newVal: regs.f.bit(C)) // new carry is copied to the bit 0
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
            
        case .rr:
            old_carry = UInt8(regs.f.bit(C))
            fallthrough
        case .rrc:
            regs.f.bit(C, newVal: operandA.bit(0)) // least significant bit is copied to the carry flag
            result = operandA >> 1
            if ulaOp == .rr {
                result.bit(7, newVal: Int(old_carry)) // old carry is copied to the bit 7
            } else {
                result.bit(7, newVal: regs.f.bit(C)) // new carry is copied to the bit 7
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
        
        case .sls:
            fallthrough
        case .sla:
            regs.f.bit(C, newVal: operandA.bit(7)) // sign bit is copied to the carry flag
            result = operandA << 1
            if ulaOp == .sls {
                result.bit(0, newVal: 1)
            }
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
            
        case .sra:
            regs.f.bit(C, newVal: operandA.bit(0)) // bit 0 is copied to the carry flag
            let sign_bit = operandA.bit(7)
            result = operandA >> 1
            result.bit(7, newVal: sign_bit) // sign bit is restored
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
        
        case .srl:
            regs.f.bit(C, newVal: operandA.bit(0)) // bit 0 is copied to the carry flag
            result = operandA >> 1
            
            regs.f.resetBit(H)
            regs.f.resetBit(N)
            regs.f.bit(PV, newVal: checkParity(result))
            
        case .and:
            fallthrough
        case .or:
            fallthrough
        case .xor:
            switch ulaOp {
            case .and:
                result = operandA & operandB
                regs.f.setBit(H)
            case .or:
                result = operandA | operandB
                regs.f.resetBit(H)
            case .xor:
                result = operandA ^ operandB
                regs.f.resetBit(H)
            default:
                break
            }
            
            regs.f.bit(PV, newVal: checkParity(result))
            regs.f.resetBit(N)
            regs.f.resetBit(C)
            
        case .bit:
            result = operandA
            
            regs.f.resetBit(S)
            
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
        
        if ulaOp != .bit {
            regs.f.bit(S, newVal: result.bit(7))
            if result == 0 {regs.f.setBit(Z)} else {regs.f.resetBit(Z)} // Z (Zero)
        }
        
        return result
    }
    
    func checkOverflow(_ opA: UInt8, _ opB: UInt8, result: UInt8, ulaOp: UlaOp) -> Int {
        // will return true if an overflow has occurred, false if no overflow
        switch ulaOp {
        case .add:
            fallthrough
        case .adc:
            if (opA.bit(7) == opB.bit(7)) && (result.bit(7) != opA.bit(7)) {
                // same sign in both operands and different sign in result
                return 1
            }
        case .sub:
            fallthrough
        case .sbc:
            if (opA.bit(7) != opB.bit(7)) && (result.bit(7) == opB.bit(7)) {
                // different sign in both operands and same sign in result
                return 1
            }
            
        default:
            break
        }
        
        return 0
    }
    
    func checkParity(_ data: UInt8) -> Int {
        return (data.parity == 0) ? 1 : 0 // 1 -> Even parity, 0 -> Odd parity
    }

    func call(_ address: UInt16) {
        t_cycle += 7
        dataBus.write(regs.sp - 1, value: regs.pc.high)
        dataBus.write(regs.sp - 2, value: regs.pc.low)
        regs.sp = regs.sp &- 2
        regs.pc = address
    }

    func ret() {
        t_cycle += 6
        regs.pc = addressFromPair(dataBus.read(regs.sp &+ 1), dataBus.read(regs.sp))
        regs.sp = regs.sp &+ 2
    }
    
    func irq(kind: IrqKind) {
        // Acknowledge an interrupt
        // NSLog("Screen Interrupt %d", t_cycle)
        switch kind {
        case .nmi:
            halted = false
            
            call(0x0066)
            regs.IFF2 = regs.IFF1
            regs.IFF1 = false
            
        case .soft:
            if regs.IFF1 {
                halted = false
                
                switch regs.int_mode {
                case 1:
                    call(0x0038)
                case 2:
                    let vector_address = addressFromPair(regs.i, dataBus.last_data & 0xFE) // reset bit 0 of the byte in dataBus to make sure we get an even address
                    let routine_address = addressFromPair(dataBus.read(vector_address + 1), dataBus.read(vector_address))
                    
                    call(routine_address)
                default:
                    break
                }
                
                regs.IFF1 = false
                regs.IFF2 = false
            }
        }
    }
}
