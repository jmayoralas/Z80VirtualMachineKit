//
//  Ula.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 12/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

private let TICS_PER_LINE = 224
private let SCREEN_LINES = 312 // 64 + 192 + 56
private let TICS_PER_FRAME = TICS_PER_LINE * SCREEN_LINES

protocol InternalUlaOperationDelegate {
    func memoryWrite(_ address: UInt16, value: UInt8)
    func ioWrite(_ address: UInt16, value: UInt8)
    func ioRead(_ address: UInt16) -> UInt8
}

private let kEmulateAudio = true

final class Ula: InternalUlaOperationDelegate, AudioStreamerDelegate {
    var memory: ULAMemory!
    var io: ULAIo!
    
    var screen: VmScreen
    
    private var borderColor: PixelData = WHITE_COLOR
    
    private var newFrame = true
    private var frameTics: Int = 0
    private var lineTics: Int = 0
    private var screenLine: Int = 0
    
    private var frames: Int = 0
    private var frameStartTime: Date!
    
    private var key_buffer = [UInt8](repeatElement(0xFF, count: 8))
    
    private var audioStreamer: AudioStreamer!
    
    private var audioData = AudioData(repeating: 0.0, count: kSamplesPerFrame)
    private var audioWave: AudioDataElement = 0
    private var dcAverage: AudioDataElement = 0
    
    private var ioData: UInt8 = 0x00
    private let semaphore = DispatchSemaphore(value: 0)
    
    init(screen: VmScreen) {
        self.screen = screen
        audioStreamer = AudioStreamer(delegate: self)
        
        memory = ULAMemory(delegate: self)
        io = ULAIo(delegate: self)
        
        screen.memory = memory
        
        if kEmulateAudio {
            audioStreamer.start()
        }
    }
    
    func step(t_cycle: Int, _ IRQ: inout Bool) {
        if newFrame {
            frameStartTime = Date()
            newFrame = false
            screen.changed = false
        }
        
        lineTics += t_cycle
        frameTics += t_cycle
        
        if kEmulateAudio {
            // sample ioData to compute new audio data
            
            var sample: AudioDataElement = (ioData & 0b00010000) > 0 ? 0.25 : -0.25
            sample += (ioData & 0b00001000) > 0 ? 0.1 : -0.1
            
            dcAverage = (dcAverage + sample) / 2
            
            audioWave -= audioWave / 8
            audioWave += sample / 8
            
            let offset: Int = (frameTics * kSamplesPerFrame) / TICS_PER_FRAME;
            if offset < kSamplesPerFrame {
                audioData[offset] = audioWave - dcAverage
            }
        }

        if lineTics > TICS_PER_LINE {
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
        lineTics -= TICS_PER_LINE
        
        screen.updateBorder(line: screenLine, color: borderColor)
        
        if screenLine >= SCREEN_LINES {
            if kEmulateAudio {
                semaphore.wait()
            }

            frames += 1
            if frames > 16 {
                screen.flashState = !screen.flashState
                screen.updateFlashing()
                frames = 0
            }
            
            newFrame = true
            frameTics -= TICS_PER_FRAME
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
    
    // MARK: AudioStreamer delegate
    func requestAudioData(sender: AudioStreamer) -> AudioData {
        semaphore.signal()
        
        return self.audioData
    }
}
