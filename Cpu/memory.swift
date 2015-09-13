//
//  memory.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 9/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

enum MemoryErrors: ErrorType {
    case MemoryNotConnected
    case UnknownError
}

class Memory {
    let pins: Pins!
    
    private var data: [UInt8] = Array(count: 0x10000, repeatedValue: 0)
    private let rom_ranges: [(start: Int, end: Int)] = [
        (0x2000, 0x3FFF)
    ]
    
    init(pins: Pins) {
        self.pins = pins
    }
    
    func clk() {
        let address = Int(pins.address_bus)
        
        // read from memory
        if pins.rd {
            print("Memory Read !")
            pins.data_bus = peek(address)
        }
        
        // write to memory
        if pins.wr {
            print("Memory Write!")
            poke(address, bytes: [pins.data_bus])
        }
    }
    
    private func isAddressReadOnly(address: Int) -> Bool {
        for range in rom_ranges {
            if range.start <= address && address <= range.end {
                return true
            }
        }
        
        return false
    }
    
    func poke(address: Int, bytes: [UInt8]) {
        var my_address = address
        if !isAddressReadOnly(address) {
            for byte in bytes {
                data[my_address++] = byte
            }
            
        }
    }
    
    func peek(address: Int) -> UInt8 {
        return data[address]
    }
}
