//
//  types.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 6/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

public struct Registers {
    // Instruction Registers
    public var ir: UInt8 = 0
    public var ir_: UInt8 = 0
    
    // Main Register Set
    // accumulator
    public var a: UInt8 = 0
    public var b: UInt8 = 0
    public var d: UInt8 = 0
    public var h: UInt8 = 0
    
    // flags
    public var f: UInt8 = 0
    public var c: UInt8 = 0
    public var e: UInt8 = 0
    public var l: UInt8 = 0
    
    // Interrupt Vector
    public var i: UInt8 = 0
    
    // Memory Refresh
    public var r: UInt8 = 0
    
    // Index Registers
    public var ixh: UInt8 = 0
    public var ixl: UInt8 = 0
    public var iyh: UInt8 = 0
    public var iyl: UInt8 = 0
    public var xxh: UInt8 = 0
    public var xxl: UInt8 = 0

    // 16 bit registers
    // primary
    var af: UInt16 {
        get {
            return UInt16(Int(Int(self.a) * 0x100) + Int(self.f))
        }
        set(newValue) {
            self.a = newValue.high
            self.f = newValue.low
        }
    }

    var bc: UInt16 {
        get {
            return UInt16(Int(Int(self.b) * 0x100) + Int(self.c))
        }
        set(newValue) {
            self.b = newValue.high
            self.c = newValue.low
        }
    }

    var hl: UInt16 {
        get {
            return UInt16(Int(Int(self.h) * 0x100) + Int(self.l))
        }
        set(newValue) {
            self.h = newValue.high
            self.l = newValue.low
        }
    }

    var de: UInt16 {
        get {
            return UInt16(Int(Int(self.d) * 0x100) + Int(self.e))
        }
        set(newValue) {
            self.d = newValue.high
            self.e = newValue.low
        }
    }
    
    // Alternate Register Set
    // accumulator
    public var af_: UInt16 = 0
    public var bc_: UInt16 = 0
    public var de_: UInt16 = 0
    public var hl_: UInt16 = 0
    
    // index
    var xx: UInt16 {
        get {
            return UInt16(Int(Int(self.xxh) * 0x100) + Int(self.xxl))
        }
        set(newValue) {
            self.xxh = newValue.high
            self.xxl = newValue.low
        }
    }
    
    var ix: UInt16 {
        get {
            return UInt16(Int(Int(self.ixh) * 0x100) + Int(self.ixl))
        }
        set(newValue) {
            self.ixh = newValue.high
            self.ixl = newValue.low
        }
    }
    
    var iy: UInt16 {
        get {
            return UInt16(Int(Int(self.iyh) * 0x100) + Int(self.iyl))
        }
        set(newValue) {
            self.iyh = newValue.high
            self.iyl = newValue.low
        }
    }
    
    // Stack Pointer
    public var sp: UInt16 = 0
    
    // Program Counter
    public var pc: UInt16 = 0
    
    // Internal software-controlled interrupt enable
    public var IFF1 : Bool = false
    public var IFF2 : Bool = false

    public var int_mode : Int = 0
}

enum UlaOp {
    case Add, Adc, Sub, Sbc, And, Or, Xor, Rlc, Rrc, Rl, Rr, Sla, Sra, Sll, Srl, Sls, Bit
}

public enum Z80Error : ErrorType {
    case ZeroBytesReadFromMemory
    case ZeroBytesWriteToMemory
}

enum IrqKind {
    case NMI, Soft
}

let S = 0
let Z = 1
let H = 3
let PV = 5
let N = 6
let C = 7

// id opcode table
let table_NONE = 0
let table_XX = 1
let table_CB = 2
let table_XXCB = 3
let table_ED = 4
