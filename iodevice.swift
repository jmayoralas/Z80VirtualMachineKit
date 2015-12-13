//
//  generic_iodevice.swift
//  z80
//
//  Created by Jose Luis Fernandez-Mayoralas on 13/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Foundation

protocol IODeviceProtocol : class {
    var port : UInt8 { get set }
    var pins : Pins { get set }
    var t_cycle : Int { get set }

    func read() -> UInt8?
    func write(data : UInt8) -> Bool
}


extension IODeviceProtocol {
    func clk() -> Void {
        // test if cpu is talking to us
        if !pins.iorq || pins.address_bus.low != port {
            t_cycle = 0
            return
        }
        
        t_cycle++
        
        switch t_cycle {
        case 1:
            // time wait to decode address
            break
        default:
            self.pins.wait = true
            
            if pins.rd {
                if let data = self.read() {
                    self.pins.data_bus = data
                    self.pins.wait = false
                }
            }
            
            if pins.wr {
                if self.write(self.pins.data_bus) {
                    self.pins.wait = false
                }
            }
        }
    }
}

class IODevice : IODeviceProtocol {
    var port : UInt8
    var pins : Pins
    var t_cycle : Int
    
    init(pins: Pins, port: UInt8) {
        self.port = port
        self.pins = pins
        self.t_cycle = 0
    }
    
    func read() -> UInt8? {
        print("read!")
        return 0x01
    }
    
    func write(data: UInt8) -> Bool {
        print("write \(data)!")
        return true
    }
}
