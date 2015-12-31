//
//  memory.swift
//  z80emu
//
//  Created by Jose Luis Fernandez-Mayoralas on 9/9/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

enum MemoryErrors: ErrorType {
    case AddressOutOfRange
    case MemoryNotConnected
    case UnknownError
}

class Memory {
    typealias RomRanges = [(start: Int, end: Int)]
    let pins: Pins!
    
    private var data: [UInt8] = Array(count: 0x10000, repeatedValue: 0)
    private var rom_ranges: RomRanges
    
    init(pins: Pins) {
        self.pins = pins
        self.rom_ranges = []
    }
    
    func clk() {
        let address = Int(pins.address_bus)
        
        // read from memory
        if pins.rd {
            pins.data_bus = peek(address)
        }
        
        // write to memory
        if pins.wr {
            poke(address, bytes: [pins.data_bus])
        }
    }
    
    func getSize() -> Int {
        return data.count
    }
    
    func poke(address: Int, bytes: [UInt8]) {
        if 0 <= address && address + bytes.count - 1 < data.count {
            var my_address = address
            if !isAddressReadOnly(address) {
                for byte in bytes {
                    data[my_address++] = byte
                }
                
            }
        }
    }
    
    func peek(address: Int) -> UInt8 {
        if address >= 0 && address < data.count {
            return data[address]
        }
        
        return 0
    }
    
    func loadRomAtAddress(address: Int, data: [UInt8]) throws {
        if address < 0 || address + data.count - 1 >= self.data.count {
            throw MemoryErrors.AddressOutOfRange
        } else {
            poke(address, bytes: data)
            
            // add this range to our ROM's table
            rom_ranges.append((start: address, end: address + data.count - 1))
        }
    }
    
    func getRomRanges() -> RomRanges {
        return rom_ranges
    }
    
    private func isAddressReadOnly(address: Int) -> Bool {
        for range in rom_ranges {
            if range.start <= address && address <= range.end {
                return true
            }
        }
        
        return false
    }
}
