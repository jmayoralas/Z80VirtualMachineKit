//
//  z80core.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

private struct Registers {
    var a: uint8 = 0
}

class Z80 {
    private var regs = Registers()
    
    private var opcodes = Array<Void -> Void>()
    
    init() {
        opcodes = [op00, op01]
    }
    
    func tic() {
        print("Tic!")
    }
    
    private func op00() { // NOP
        print("opcode 00")
    }
    
    private func op01() {
        print("opcode 01")
    }
}