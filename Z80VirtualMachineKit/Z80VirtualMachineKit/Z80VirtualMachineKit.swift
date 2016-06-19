//
//  VirtualMachine.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 31/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

public enum RomErrors: ErrorProtocol {
    case bufferLimitReach
}

@objc public protocol Z80VirtualMachineStatus {
    @objc optional func Z80VMMemoryWriteAtAddress(_ address: Int, byte: UInt8)
    @objc optional func Z80VMMemoryReadAtAddress(_ address: Int, byte: UInt8)
    @objc optional func Z80VMScreenRefresh(_ image: NSImage)
    @objc optional func Z80VMEmulationHalted()
}

@objc final public class Z80VirtualMachineKit: NSObject, MemoryChange
{
    // MARK: Properties
    public var delegate: Z80VirtualMachineStatus?
    
    private let cpu = Z80(dataBus: Bus16(), ioBus: IoBus())
    private var instructions = 0
    private var ula = Ula()
    private let rom = Rom(base_address: 0x0000, block_size: 0x4000)
    private var t_cycles: Int = 0
    
    private var irq_enabled = true
    
    // MARK: Constructor
    override public init() {
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
        cpu.halted = false
        
        let queue = DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(Int(DispatchQueueAttributes.qosUserInitiated.rawValue))))
        
        queue.async {
            repeat {
                self.step()
            } while !self.cpu.halted
            
            self.delegate?.Z80VMScreenRefresh?(self.ula.getScreen())
            self.delegate?.Z80VMEmulationHalted?()
        }
    }
    
    public func stop() {
        cpu.halted = true;
    }
    
    public func step() {
        var IRQ = false
        
        instructions += 1
        
        cpu.t_cycle = 0
        
        cpu.step()
        ula.step(t_cycle: cpu.t_cycle, &IRQ)
        
        t_cycles += cpu.t_cycle
/*
        if instructions > 824000 && cpu.regs.pc == 0x0298 && cpu.regs.bc == 0xBFFE  && cpu.regs.sp == 0xFF3A {
            cpu.regs.a = 0xFB
            cpu.regs.f = 0b10010101
            t_cycles = 7618271
            instructions = 824514
            irq_enabled = false
        }
*/        
        if instructions == 824514 {
            cpu.halted = true
        }

        if IRQ {
            if irq_enabled {
                cpu.irq(kind: .soft)
            }
            
            IRQ = false
            delegate?.Z80VMScreenRefresh?(ula.getScreen())
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
        
        delegate?.Z80VMScreenRefresh?(ula.getScreen())
    }
    
    public func dumpMemoryFromAddress(_ fromAddress: Int, toAddress: Int) -> [UInt8] {
        return cpu.dataBus.dumpFromAddress(fromAddress, count: toAddress - fromAddress + 1)
    }
    
    public func keyPressed(theEvent: NSEvent) {
        let address: UInt8
        let value: UInt8
        
        switch theEvent.keyCode {
        case 36:
            address = 0xBF
            value = 0b11111110
        default:
            address = 0xBF
            value = 0b11110111
        }
        
        ula.updateKeyboardBuffer(address: address, value: value)
    }
    
    public func isRunning() -> Bool {
        return !cpu.halted
    }
    // MARK: protocol MemoryChange
    func MemoryWriteAtAddress(_ address: Int, byte: UInt8) {
        delegate?.Z80VMMemoryWriteAtAddress?(address, byte: byte)
    }
    
    func MemoryReadAtAddress(_ address: Int, byte: UInt8) {
        delegate?.Z80VMMemoryReadAtAddress?(address, byte: byte)
    }
}
