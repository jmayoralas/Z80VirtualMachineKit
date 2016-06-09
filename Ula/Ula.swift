//
//  Ula.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 12/5/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

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

protocol UlaDelegate {
    func memoryWrite(address: UInt16, value: UInt8)
    func ioWrite(address: UInt16, value: UInt8)
    func ioRead(address: UInt16) -> UInt8
}

final class Ula: UlaDelegate {
    var memory: ULAMemory!
    var io: ULAIo!
    
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
    private var screen = [PixelData](count: 320 * 240, repeatedValue: PixelData(a: 255, r: 0xCD, g: 0xCD, b: 0xCD))
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
    
    init() {
        memory = ULAMemory(delegate: self)
        io = ULAIo(delegate: self)
    }
    
    func memoryWrite(address: UInt16, value: UInt8) {
        let local_address = address & 0x3FFF
        if local_address > 0x1AFF {
            return
        }
        
        if local_address < 0x1800 {
            // bitmap area
            let x = Int((local_address.low & 0b00011111))
            let y = (Int(((local_address.high & 0b00011000) << 3) | ((local_address.low & 0b11100000) >> 5) | ((local_address.high & 0b00000111) << 3)))
            
            let attribute_address = 0x5800 + x + (y / 8) * 32
            let attribute = getAttribute(Int(memory.read(UInt16(attribute_address))))
            
            fillScreenEightBitLineAt(char: x, line: y, value: value, attribute: attribute)
        } else {
            // attr area
            let attribute = getAttribute(Int(value))
            updateCharAtOffset(Int(local_address) & 0x7FF, attribute: attribute)
        }
    }
    
    func ioRead(address: UInt16) -> UInt8 {
        NSLog("Reading from ULAIo address: %@", address.hexStr())
        return 0xFF
    }
    
    func ioWrite(address: UInt16, value: UInt8)  {
        NSLog("Writing to ULAIo address: %@, value: %@", address.hexStr(), value.hexStr())
    }
    
    func getScreen() -> NSImage {
        return imageFromARGB32Bitmap(screen, width: 320, height: 240)
    }
    
    private func updateCharAtOffset(offset: Int, attribute: Attribute) {
        let y = (offset / 32) * 8
        let x = offset % 32
        
        let line_address: UInt16 = UInt16(0x4000 + y * 32 + x)
        
        for i in 0...7 {
            fillScreenEightBitLineAt(char: x, line: y + i, value: memory.read(line_address + UInt16(i * 32)), attribute: attribute)
        }
    }
    
    private func fillScreenEightBitLineAt(char x: Int, line y: Int, value: UInt8, attribute: Attribute) {
        let index = (y + 24) * 320 + x * 8 + 32
        
        var j = 0
        
        for i in (0...7).reverse() {
            screen[index + j] = ((Int(value) & 1 << i) > 0) ? attribute.inkColor : attribute.paperColor
            j += 1
        }
    }
    
    private func imageFromARGB32Bitmap(pixels:[PixelData], width:Int, height:Int) -> NSImage {
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        assert(pixels.count == width * height)
        
        var data = pixels // Copy to mutable []
        let providerRef = CGDataProviderCreateWithCFData(
            NSData(bytes: &data, length: data.count * sizeof(PixelData))
        )
        
        let cgim = CGImageCreate(
            width,
            height,
            bitsPerComponent,
            bitsPerPixel,
            width * sizeof(PixelData),
            rgbColorSpace,
            bitmapInfo,
            providerRef,
            nil,
            true,
            CGColorRenderingIntent.RenderingIntentDefault
        )
        
        return NSImage(CGImage: cgim!, size: NSZeroSize)
    }
    
    private func getAttribute(value: Int) -> Attribute {
        return Attribute(
            flashing: (value & 0b10000000) > 0 ? true : false,
            paperColor: colorTable[(value >> 3) & 0b00001111],
            inkColor: colorTable[((value >> 3) & 0b00001000) | (value & 0b00000111)]
        )
    }
}