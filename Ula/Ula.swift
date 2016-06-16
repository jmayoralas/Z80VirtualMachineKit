//
//  Ula.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 12/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

protocol UlaDelegate {
    func onFrameCompleted()
}

private struct PixelData {
    var a:UInt8 = 255
    var r:UInt8
    var g:UInt8
    var b:UInt8
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
    var delegate: UlaDelegate?
    
    private let TICS_PER_FRAME = 69888
    
    var memory: ULAMemory!
    var io: ULAIo!
    
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    private var screen = [PixelData](repeating: PixelData(a: 255, r: 0xCD, g: 0xCD, b: 0xCD), count: 320 * 240)
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
    
    private var frameTics: Int = 0
    
    init() {
        memory = ULAMemory(delegate: self)
        io = ULAIo(delegate: self)
    }
    
    func step(t_cycle: Int) {
        frameTics += t_cycle
        if frameTics >= TICS_PER_FRAME {
            delegate?.onFrameCompleted()
            frameTics -= TICS_PER_FRAME
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
        NSLog("Reading from ULAIo address: %@", address.hexStr())
        return 0xFF
    }
    
    func ioWrite(_ address: UInt16, value: UInt8)  {
        NSLog("Writing to ULAIo address: %@, value: %@", address.hexStr(), value.hexStr())
    }
    
    func getScreen() -> NSImage {
        return imageFromARGB32Bitmap(screen, width: 320, height: 240)
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
        let index = (y + 24) * 320 + x * 8 + 32
        var j = 0
        
        for i in (0...7).reversed() {
            screen[index + j] = ((Int(value) & 1 << i) > 0) ? attribute.inkColor : attribute.paperColor
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
}
