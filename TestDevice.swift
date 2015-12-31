//
//  iodevice_test.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 13/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

class TestDevice : IODevice {
    var test_device_t_cycle : Int
    var irq_pending : Bool
    
    override init(pins: Pins, port: UInt8) {
        test_device_t_cycle = 0
        irq_pending = true
        
        super.init(pins: pins, port: port)
    }
    
    override func read() -> UInt8? {
        print("T: \(t_cycle)")
        if t_cycle == 4 {
            print("test device read! T: \(t_cycle)")
            return 0xFF
        }
        
        return nil
    }
    
    override func write(data: UInt8) -> Bool {
        print("T: \(t_cycle)")
        if t_cycle == 4 {
            print("test device write \(data) T: \(t_cycle)")
            return true
        }
        return false
    }
    
    override func irq() -> IrqKind? {
        test_device_t_cycle++
        
        if test_device_t_cycle == 7 && irq_pending {
            irq_pending = false
            test_device_t_cycle = 0
            return .NMI
        }
        
        return nil
    }
}
