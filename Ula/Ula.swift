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
    
    private var screen: VmScreen
    private let colorTable = [
        PixelData(a: 255, r: 0, g: 0, b: 0),
        PixelData(a: 255, r: 0, g: 0, b: 0xCD),
        PixelData(a: 255, r: 0xCD, g: 0, b: 0),
        PixelData(a: 255, r: 0xCD, g: 0, b: 0xCD),
        PixelData(a: 255, r: 0, g: 0xCD, b: 0),
        PixelData(a: 255, r: 0, g: 0xCD, b: 0xCD),
        PixelData(a: 255, r: 0xCD, g: 0xCD, b: 0),
        PixelData(a: 255, r: 0xCD, g: 0xCD, b: 0xCD),
        
        PixelData(a: 255, r: 0, g: 0, b: 0),
        PixelData(a: 255, r: 0, g: 0, b: 0xFF),
        PixelData(a: 255, r: 0xFF, g: 0, b: 0),
        PixelData(a: 255, r: 0xFF, g: 0, b: 0xFF),
        PixelData(a: 255, r: 0, g: 0xFF, b: 0),
        PixelData(a: 255, r: 0, g: 0xFF, b: 0xFF),
        PixelData(a: 255, r: 0xFF, g: 0xFF, b: 0),
        PixelData(a: 255, r: 0xFF, g: 0xFF, b: 0xFF),
    ]
    
    private var borderColor: PixelData = WHITE_COLOR
    
    private var newFrame = true
    private var frameTics: Int = 0
    private var lineTics: Int = 0
    private var screenLine: Int = 0
    private var flashState: Bool = false
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
        
        if kEmulateAudio {
            audioStreamer.start()
        }
    }
    
    func step(t_cycle: Int, _ IRQ: inout Bool) {
        if newFrame {
            frameStartTime = Date()
            newFrame = false
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
    private func updateCharAtOffset(_ offset: Int, attribute: Attribute) {
        let y = (offset / 32) * 8
        let x = offset % 32
        
        let line_address = UInt16(0x4000 + y * 32 + x)
        let line_address_corrected = (line_address & 0xF800) | ((line_address & 0x700) >> 3) | ((line_address & 0xE0) << 3) | (line_address & 0x1F)
        
        for i in 0...7 {
            fillScreenEightBitLineAt(char: x, line: y + i, value: memory.read(line_address_corrected + UInt16(i * 0x100)), attribute: attribute)
        }
    }
    
    private func fillScreenEightBitLineAt(char x: Int, line y: Int, value: UInt8, attribute: Attribute) {
        
        let inkColor: PixelData!
        let paperColor: PixelData!
        
        if flashState && attribute.flashing {
            inkColor = attribute.paperColor
            paperColor = attribute.inkColor
        } else {
            inkColor = attribute.inkColor
            paperColor = attribute.paperColor
        }
        let index = (y + 24) * 320 + x * 8 + 32
        var j = 0
        
        for i in (0...7).reversed() {
            screen.buffer[index + j] = ((Int(value) & 1 << i) > 0) ? inkColor : paperColor
            j += 1
        }
    }

    
    private func getAttribute(_ value: Int) -> Attribute {
        return Attribute(
            flashing: (value & 0b10000000) > 0 ? true : false,
            paperColor: colorTable[(value >> 3) & 0b00001111],
            inkColor: colorTable[((value >> 3) & 0b00001000) | (value & 0b00000111)]
        )
    }
    
    private func screenLineCompleted(_ IRQ: inout Bool) {
        screenLine += 1
        lineTics -= TICS_PER_LINE
        
        if 36 <= screenLine && screenLine <= 239 + 36 {
            // the line is on the visible area of the screen
            // update border color if we have to
            let bitmapLine = screenLine - 36
            let index = bitmapLine * 320
            
            // the bitmapLine background color has changed ?
            if screen.buffer[index] != borderColor {
                if 24 <= bitmapLine && bitmapLine < 24 + 192 {
                    // bitmap border
                    for i in 0..<32 {
                        screen.buffer[index + i] = borderColor
                    }
                    for i in 256 + 32..<320 {
                        screen.buffer[index + i] = borderColor
                    }
                } else {
                    // above and below bitmap area border
                    for i in 0..<320 {
                        screen.buffer[index + i] = borderColor
                    }
                }
            }
        }
        
        if screenLine >= SCREEN_LINES {
            if kEmulateAudio {
                semaphore.wait()
            }

            frames += 1
            if frames > 16 {
                flashState = !flashState
                updateScreenFlashing()
                frames = 0
            }
            
            newFrame = true
            frameTics -= TICS_PER_FRAME
            screenLine = 0
            
            IRQ = true
        }
    }
    
    private func updateScreenFlashing() {
        for i in 0..<0x300 {
            updateCharAtOffset(i, attribute: getAttribute(Int(memory.read(0x5800 + UInt16(i)))))
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
            let attribute = getAttribute(Int(memory.read(UInt16(attribute_address))))
            
            fillScreenEightBitLineAt(char: x, line: y, value: value, attribute: attribute)
        } else {
            // attr area
            let attribute = getAttribute(Int(value))
            updateCharAtOffset(Int(local_address) & 0x7FF, attribute: attribute)
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
