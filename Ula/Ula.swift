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
private let WHITE_COLOR = PixelData(a: 255, r: 0xCD, g: 0xCD, b: 0xCD)

private struct PixelData {
    var a:UInt8 = 255
    var r:UInt8
    var g:UInt8
    var b:UInt8
}

extension PixelData: Equatable {}
    private func ==(lhs: PixelData, rhs: PixelData) -> Bool {
        return lhs.a == rhs.a && lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
    }

private struct Attribute {
    var flashing: Bool
    var paperColor: PixelData
    var inkColor: PixelData
}

protocol InternalUlaOperationDelegate {
    func memoryWrite(_ address: UInt16, value: UInt8)
    func ioWrite(_ address: UInt16, value: UInt8)
    func ioRead(_ address: UInt16) -> UInt8
}

final class Ula: InternalUlaOperationDelegate {
    var memory: ULAMemory!
    var io: ULAIo!
    
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    private var screen = [PixelData](repeating: WHITE_COLOR, count: 320 * 240)
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
    
    private var frameTics: Int = 0
    private var lineTics: Int = 0
    private var screenLine: Int = 0
    private var flashState: Bool = false
    private var frames: Int = 0
    
    private var key_buffer = [UInt8](repeatElement(0xFF, count: 0xFF))
    
    init() {
        memory = ULAMemory(delegate: self)
        io = ULAIo(delegate: self)
    }
    
    func step(t_cycle: Int, _ IRQ: inout Bool) {
        lineTics += t_cycle
        frameTics += t_cycle
        
        if lineTics > TICS_PER_LINE {
            screenLineCompleted(&IRQ)
        }
    }
    
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
        return key_buffer[Int(address.high)]
    }
    
    func ioWrite(_ address: UInt16, value: UInt8)  {
        // get the border color from value
        borderColor = colorTable[Int(value) & 0x07]
    }
    
    func getScreen() -> NSImage {
        return imageFromARGB32Bitmap(screen, width: 320, height: 240)
    }
    
    func keyDown(address: UInt8, value: UInt8) {
        key_buffer[Int(address)] = key_buffer[Int(address)] & value
    }
    
    func keyUp(address: UInt8, value: UInt8) {
        key_buffer[Int(address)] = key_buffer[Int(address)] | ~value
    }
    
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
            screen[index + j] = ((Int(value) & 1 << i) > 0) ? inkColor : paperColor
            j += 1
        }
    }
    
    private func imageFromARGB32Bitmap(_ pixels:[PixelData], width:Int, height:Int) -> NSImage {
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        assert(pixels.count == width * height)
        
        let providerRef = CGDataProvider(
            data: Data(bytes: UnsafePointer<UInt8>(pixels), count: pixels.count * sizeof(PixelData))
        )
        
        let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * sizeof(PixelData),
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        return NSImage(cgImage: cgim!, size: NSZeroSize)
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
            if screen[index] != borderColor {
                if 24 <= bitmapLine && bitmapLine < 24 + 192 {
                    // bitmap border
                    for i in 0..<32 {
                        screen[index + i] = borderColor
                    }
                    for i in 256 + 32..<320 {
                        screen[index + i] = borderColor
                    }
                } else {
                    // above and below bitmap area border
                    for i in 0..<320 {
                        screen[index + i] = borderColor
                    }
                }
            }
        }
        
        if screenLine >= SCREEN_LINES {
            frames += 1
            if frames > 16 {
                flashState = !flashState
                updateScreenFlashing()
                frames = 0
            }
            
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
}
