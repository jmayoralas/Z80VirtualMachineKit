//
//  types.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 6/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

class Pins {
    var address_bus: UInt16 = 0
    var data_bus: UInt8 = 0
    var busack: Bool = false
    var busreq: Bool = false
    var halt: Bool = false
    var int: Bool = false
    var iorq: Bool = false
    var m1: Bool = false
    var mreq: Bool = false
    var nmi: Bool = false // positive edge triggered (false -> true)
    var rd: Bool = false
    var reset: Bool = false
    var rfsh: Bool = false
    var wait: Bool = false
    var wr: Bool = false
}

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
    
    // Alternate Register Set
    // accumulator
    public var a_: UInt8 = 0
    public var b_: UInt8 = 0
    public var d_: UInt8 = 0
    public var h_: UInt8 = 0
    
    // flags
    public var f_: UInt8 = 0
    public var c_: UInt8 = 0
    public var e_: UInt8 = 0
    public var l_: UInt8 = 0
    
    // Interrupt Vector
    public var i: UInt8 = 0
    
    // Memory Refresh
    public var r: UInt8 = 0
    
    // Index Registers
    public var ixh: UInt8 = 0
    public var ixl: UInt8 = 0
    public var iyh: UInt8 = 0
    public var iyl: UInt8 = 0
    
    // Stack Pointer
    public var sp: UInt16 = 0
    
    // Program Counter
    public var pc: UInt16 = 0
    
    // Internal software-controlled interrupt enable
    public var IFF1 : Bool = false
    public var IFF2 : Bool = false

    public var int_mode : Int = 0
}

enum MachineCycle: Int {
    case OpcodeFetch = 1, MemoryRead, MemoryWrite, IoRead, IoWrite, UlaOperation, TimeWait, SoftIrq, NMIrq
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

let prefix_NONE = 0
let prefix_DD = 1
let prefix_FD = 2
let prefix_CB = 3
let prefix_DDCB = 4
let prefix_FDCB = 5
let prefix_ED = 6
