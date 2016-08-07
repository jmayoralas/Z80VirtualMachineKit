//
//  VirtualMachine.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 31/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

private let WHITE_COLOR = PixelData(a: 255, r: 0xCD, g: 0xCD, b: 0xCD)

public enum RomErrors: ErrorProtocol {
    case bufferLimitReach
}

@objc final public class VmScreen: NSObject {
    public var buffer = [PixelData](repeating: WHITE_COLOR, count: 320 * 240)
}

public struct SpecialKeys: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let capsShift = SpecialKeys(rawValue: 1)
    public static let symbolShift = SpecialKeys(rawValue: 1 << 1)
}

private enum UlaKeyOperation {
    case down
    case up
}

private struct UlaUpdateData {
    var address: UInt8?
    var value: UInt8
}

@objc public protocol Z80VirtualMachineStatus {
    @objc optional func Z80VMMemoryWriteAtAddress(_ address: Int, byte: UInt8)
    @objc optional func Z80VMMemoryReadAtAddress(_ address: Int, byte: UInt8)
    @objc optional func Z80VMScreenRefresh()
    @objc optional func Z80VMEmulationHalted()
}

@objc final public class Z80VirtualMachineKit: NSObject, MemoryChange
{
    // MARK: Properties
    public var delegate: Z80VirtualMachineStatus?
    
    private let cpu = Z80(dataBus: Bus16(), ioBus: IoBus())
    private var instructions = 0
    private var ula: Ula
    private let rom = Rom(base_address: 0x0000, block_size: 0x4000)
    private var t_cycles: Int = 0
    
    private var irq_enabled = true
    
    private struct KeyboardRow {
        let address: UInt8
        let keys: [Character]
    }
    
    private var keyboard = [
        KeyboardRow(address: 0xFE, keys: ["-","z","x","c","v"]),
        KeyboardRow(address: 0xFD, keys: ["a","s","d","f","g"]),
        KeyboardRow(address: 0xFB, keys: ["q","w","e","r","t"]),
        KeyboardRow(address: 0xF7, keys: ["1","2","3","4","5"]),
        KeyboardRow(address: 0xEF, keys: ["0","9","8","7","6"]),
        KeyboardRow(address: 0xDF, keys: ["p","o","i","u","y"]),
        KeyboardRow(address: 0xBF, keys: ["*","l","k","j","h"]),
        KeyboardRow(address: 0x7F, keys: [" ","-","m","n","b"]),
    ]
    
    private let capsShiftUlaUpdateData = UlaUpdateData(address: 0xFE, value: 0b11111110)
    private let symbolShiftUlaUpdateData = UlaUpdateData(address: 0x7F, value: 0b11111101)
    private var previousSpecialKeys = SpecialKeys()
    
    // MARK: Constructor
    public init(_ screen: VmScreen) {
        ula = Ula(screen: screen)
        
        super.init()
        
        // connect the 16k ROM
        rom.delegate = self
        cpu.dataBus.addBusComponent(rom)
        
        // connect the ULA and his 16k of memory (this is a Spectrum 16k)
        ula.memory.delegate = self
        
        cpu.dataBus.addBusComponent(ula.memory)
        cpu.ioBus.addBusComponent(ula.io)
        
        // add the upper 32k to emulate a 48k Spectrum
        let ram = Ram(base_address: 0x8000, block_size: 0x8000)
        ram.delegate = self
        cpu.dataBus.addBusComponent(ram)
        
        cpu.reset()
    }
    
    // MARK: Methods
    public func reset() {
        cpu.reset()
        instructions = 0
        t_cycles = 0
    }
    
    public func run() {
        cpu.stopped = false
        
        let queue = DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(Int(DispatchQueueAttributes.qosUserInitiated.rawValue))))
        
        queue.async {
            repeat {
                self.step()
            } while !self.cpu.stopped
            
            self.delegate?.Z80VMScreenRefresh?()
            self.delegate?.Z80VMEmulationHalted?()
        }
    }
    
    public func stop() {
        cpu.stopped = true;
    }
    
    public func step() {
        var IRQ = false
        
        instructions += 1
        
        cpu.t_cycle = 0
        
        cpu.step()
        ula.step(t_cycle: cpu.t_cycle, &IRQ)
        
        t_cycles = cpu.t_cycle
/*
        if instructions > 824000 && cpu.regs.pc == 0x0298 && cpu.regs.bc == 0xBFFE  && cpu.regs.sp == 0xFF3A {
            cpu.regs.a = 0xFB
            cpu.regs.f = 0b10010101
            t_cycles = 7618271
            instructions = 824514
            irq_enabled = false
        }

        if cpu.regs.pc == 0x82BA && cpu.regs.sp == 0x8800 && cpu.addressFromPair(cpu.dataBus.read(cpu.regs.sp + 1), cpu.dataBus.read(cpu.regs.sp)) == 0x86c1 && cpu.regs.r == 0x8D {
            cpu.stopped = true
        }
*/
        if IRQ {
            if irq_enabled {
                cpu.irq(kind: .soft)
            }
            
            IRQ = false
            delegate?.Z80VMScreenRefresh?()
        }
    }
    
    public func getInstructionsCount() -> Int {
        return instructions < 0 ? 0 : instructions
    }
    
    public func addIoDevice(_ port: UInt8) {
        cpu.ioBus.addBusComponent(GenericIODevice(base_address: UInt16(port), block_size: 1))
    }
    
    public func loadRamAtAddress(_ address: Int, data: [UInt8]) {
        for i in 0..<data.count {
            cpu.dataBus.write(UInt16(address + i), value: data[i])
        }
    }
    
    public func loadRomAtAddress(_ address: Int, data: [UInt8]) throws {
        try rom.loadData(data, atAddress: address)
    }
    
    public func getCpuRegs() -> Registers {
        return cpu.getRegs()
    }
    
    public func getTCycle() -> Int {
        return t_cycles
    }
    
    public func setPc(_ pc: UInt16) {
        cpu.org(pc)
    }
    
    public func clearMemory() {
        for address in 0x4000...0xFFFF {
            if (0x5800 <= address) && (address < 0x5B00) {
                cpu.dataBus.write(UInt16(address), value: 0x38)
            } else {
                cpu.dataBus.write(UInt16(address), value: 0x00)
            }
            
        }
        
        delegate?.Z80VMScreenRefresh?()
    }
    
    
    public func isRunning() -> Bool {
        return !cpu.stopped
    }
    
    public func dumpMemoryFromAddress(_ fromAddress: Int, toAddress: Int) -> [UInt8] {
        return cpu.dataBus.dumpFromAddress(fromAddress, count: toAddress - fromAddress + 1)
    }
    
    // MARK: Keyboard management
    public func keyDown(char: Character) {
        let lchar = char == "@" ? "0" : char
        
        // treat special combination for backspace
        if char == "@" {
            updateUla(operation: .down, data: capsShiftUlaUpdateData)
        }
        updateUla(operation: .down, data: getKeyboardUlaUpdateData(char: lchar))
    }
    
    public func keyUp(char: Character) {
        let lchar = char == "@" ? "0" : char
        
        // treat special combination for backspace
        if char == "@" {
            updateUla(operation: .up, data: capsShiftUlaUpdateData)
        }
        updateUla(operation: .up, data: getKeyboardUlaUpdateData(char: lchar))
    }
    
    public func specialKeyUpdate(special_keys: SpecialKeys) {
        var op: UlaKeyOperation = special_keys.contains(SpecialKeys.capsShift) ? .down : .up
        if (!previousSpecialKeys.contains(SpecialKeys.capsShift) && op == .down) || (previousSpecialKeys.contains(SpecialKeys.capsShift) && op == .up) {
            updateUla(operation: op, data: capsShiftUlaUpdateData)
        }
        
        op = special_keys.contains(SpecialKeys.symbolShift) ? .down : .up
        if (!previousSpecialKeys.contains(SpecialKeys.symbolShift) && op == .down) || (previousSpecialKeys.contains(SpecialKeys.symbolShift) && op == .up) {
            updateUla(operation: op, data: symbolShiftUlaUpdateData)
        }
        
        previousSpecialKeys = special_keys
    }
    
    
    
    private func updateUla(operation: UlaKeyOperation, data: UlaUpdateData) {
        if let address = data.address {
            switch operation {
            case .down:
                ula.keyDown(address: address, value: data.value)
            case .up:
                ula.keyUp(address: address, value: data.value)
            }
        }
    }
    
    private func getKeyboardUlaUpdateData(char: Character) -> UlaUpdateData  {
        var result = UlaUpdateData(address: nil, value: 0xFF)
        
        for row in keyboard {
            if row.keys.contains(char) {
                result.address = row.address
                result.value = getValue(char: char, keys: row.keys)
                break
            }
        }
        
        return result
    }
    
    private func getValue(char: Character, keys: [Character]) -> UInt8 {
        var value: UInt8 = 0xFF
        
        for (index,lchar) in keys.enumerated() {
            if lchar == char {
                value.resetBit(index)
            }
        }
        
        return value
    }
    
    // MARK: protocol MemoryChange
    func MemoryWriteAtAddress(_ address: Int, byte: UInt8) {
        delegate?.Z80VMMemoryWriteAtAddress?(address, byte: byte)
    }
    
    func MemoryReadAtAddress(_ address: Int, byte: UInt8) {
        delegate?.Z80VMMemoryReadAtAddress?(address, byte: byte)
    }
}
