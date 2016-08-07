//
//  VmScreen.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 7/8/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

let WHITE_COLOR = PixelData(a: 255, r: 0xCD, g: 0xCD, b: 0xCD)

public struct PixelData {
    var a:UInt8 = 255
    var r:UInt8
    var g:UInt8
    var b:UInt8
}

extension PixelData: Equatable {}
public func ==(lhs: PixelData, rhs: PixelData) -> Bool {
    return lhs.a == rhs.a && lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
}

struct Attribute {
    var flashing: Bool
    var paperColor: PixelData
    var inkColor: PixelData
}



@objc final public class VmScreen: NSObject {
    var buffer = [PixelData](repeating: WHITE_COLOR, count: 320 * 240)
    
    public func getBuffer(width: Int) -> [PixelData] {
        return buffer
    }
}
