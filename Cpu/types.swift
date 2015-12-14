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

struct Registers {
    // Instruction Register
    var ir: UInt8 = 0
    
    // Main Register Set
    // accumulator
    var a: UInt8 = 0
    var b: UInt8 = 0
    var d: UInt8 = 0
    var h: UInt8 = 0
    
    // flags
    var f: UInt8 = 0
    var c: UInt8 = 0
    var e: UInt8 = 0
    var l: UInt8 = 0
    
    // Alternate Register Set
    // accumulator
    var a_: UInt8 = 0
    var b_: UInt8 = 0
    var d_: UInt8 = 0
    var h_: UInt8 = 0
    
    // flags
    var f_: UInt8 = 0
    var c_: UInt8 = 0
    var e_: UInt8 = 0
    var l_: UInt8 = 0
    
    // Interrupt Vector
    var i: UInt8 = 0
    
    // Memory Refresh
    var r: UInt8 = 0
    
    // Index Registers
    var ixh: UInt8 = 0
    var ixl: UInt8 = 0
    var iyh: UInt8 = 0
    var iyl: UInt8 = 0
    
    // Stack Pointer
    var sp: UInt16 = 0
    
    // Program Counter
    var pc: UInt16 = 0
    
    // Internal software-controlled interrupt enable
    var IFF1 : Bool = false
    var IFF2 : Bool = false

}

enum MachineCycle: Int {
    case OpcodeFetch = 1, MemoryRead, MemoryWrite, IoRead, IoWrite, UlaOperation, TimeWait
}

enum UlaOp {
    case Add, Adc, Sub, Sbc, And, Or, Xor, Rlc, Rrc, Rl, Rr, Sla, Sra, Sll, Srl
}

public enum Z80Error : ErrorType {
    case ZeroBytesReadFromMemory
    case ZeroBytesWriteToMemory
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
