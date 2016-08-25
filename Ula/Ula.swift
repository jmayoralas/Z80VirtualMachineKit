//
//  Ula.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 12/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

protocol InternalUlaOperationDelegate {
    func memoryWrite(_ address: UInt16, value: UInt8)
    func ioWrite(_ address: UInt16, value: UInt8)
    func ioRead(_ address: UInt16) -> UInt8
}

final class Ula: InternalUlaOperationDelegate {
    var memory: ULAMemory!
    var io: ULAIo!
    
    var screen: VmScreen
    
    private var borderColor: PixelData = kWhiteColor
    
    private var newFrame = true
    private var frameTics: Int = 0
    private var lineTics: Int = 0
    private var screenLine: Int = 0
    
    private var frames: Int = 0
    
    private var key_buffer = [UInt8](repeatElement(0xFF, count: 8))
    
    private var audioStreamer: AudioStreamer!
    
    private var ioData: UInt8 = 0x00
    
    var audioEnabled = true

    
    init(screen: VmScreen) {
        self.screen = screen
        audioStreamer = AudioStreamer()
        
        memory = ULAMemory(delegate: self)
        io = ULAIo(delegate: self)
        
        screen.memory = memory
    }
    
    func step(t_cycle: Int, _ IRQ: inout Bool) {
        if newFrame {
            newFrame = false
            screen.beginFrame()
        }
        
        lineTics += t_cycle
        frameTics += t_cycle
        
        if audioEnabled {
            // sample ioData to compute new audio data
            self.audioStreamer.updateSample(tCycle: frameTics, value: self.ioData)
        }

        if lineTics > kTicsPerLine {
            screenLineCompleted(&IRQ)
        }
    }
    
    // MARK: Keyboard management
    func keyDown(address: UInt8, value: UInt8) {
        for i in 0 ..< 8 {
            if (Int(address) >> i) & 0x01 == 0 {
                key_buffer[i] = key_buffer[i] & value
            }
        }
    }
    
    func keyUp(address: UInt8, value: UInt8) {
        for i in 0 ..< 8 {
            if (Int(address) >> i) & 0x01 == 0 {
                key_buffer[i] = key_buffer[i] | ~value
            }
        }
    }
    
    // MARK: Screen management
    private func screenLineCompleted(_ IRQ: inout Bool) {
        screenLine += 1
        lineTics -= kTicsPerLine
        
        screen.updateBorder(line: screenLine, color: borderColor)
        
        if screenLine >= kScreenLines {
            if audioEnabled {
                self.audioStreamer.endFrame()
            }

            frames += 1
            if frames > 16 {
                screen.flashState = !screen.flashState
                screen.updateFlashing()
                frames = 0
            }
            
            newFrame = true
            frameTics -= kTicsPerFrame
            screenLine = 0
            
            IRQ = true
        }
    }
    
    // MARK: InternalUlaOperation delegate
    func memoryWrite(_ address: UInt16, value: UInt8) {
        let local_address = address & 0x3FFF
        if local_address > 0x1AFF {
            return
        }
        
        if local_address < 0x1800 {
            // bitmap area
            let x = Int((local_address.low & 0b00011111))
            let y = Int(((local_address.high & 0b00011000) << 3) | ((local_address.low & 0b11100000) >> 2) | (local_address.high & 0b00000111))
            
            let attribute_address = 0x5800 + x + (y / 8) * 32
            screen.fillEightBitLineAt(char: x, line: y, value: value, attribute: VmScreen.getAttribute(Int(memory.read(UInt16(attribute_address)))))
        } else {
            // attr area
            screen.updateCharAtOffset(Int(local_address) & 0x7FF, attribute: VmScreen.getAttribute(Int(value)))
        }
    }
    
    func ioRead(_ address: UInt16) -> UInt8 {
        var key_scanned: UInt8 = 0b10111111
        
        for i in 0 ..< 8 {
            if (Int(address.high) >> i) & 0x01 == 0 {
                key_scanned = key_scanned & key_buffer[i]
            }
        }
        return key_scanned
    }
    
    func ioWrite(_ address: UInt16, value: UInt8)  {
        self.ioData = value
        
        // get the border color from value
        borderColor = colorTable[Int(value) & 0x07]
    }
}
