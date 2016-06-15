//
//  ColorChangeTextFieldCell.swift
//  DebuggerZ80VirtualMachine
//
//  Created by Jose Luis Fernandez-Mayoralas on 1/1/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Cocoa

class ColorChangeTextField : NSTextField {
    var originalTextColor : NSColor?
    
    override var stringValue: String {
        get {
            return super.stringValue
        }
        set {
            if super.stringValue != newValue {
                if originalTextColor == nil {
                    originalTextColor = super.textColor
                }
                super.textColor = NSColor.red()
            } else {
                super.textColor = originalTextColor
            }
            super.stringValue = newValue
        }
    }
}
