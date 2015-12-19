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
    var int_requested : Bool { get set }

    func read() -> UInt8?
    func write(data : UInt8) -> Bool
    func irq() -> Bool
}


extension IODeviceProtocol {
    func clk() -> Void {
        t_cycle++
        
        if int_requested {
            if pins.m1 && pins.iorq {
                pins.wait = true
                if let data = self.read() {
                    pins.data_bus = data
                    pins.wait = false
                    int_requested = false
                }
            } else {
                t_cycle = 0
            }
        } else {
            // test if cpu is talking to us
            if !pins.iorq || pins.address_bus.low != port {
                t_cycle = 0
                if irq() {
                    int_requested = true
                    pins.int = true
                }
                return
            }
            
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
}

class IODevice : IODeviceProtocol {
    var port : UInt8
    var pins : Pins
    var t_cycle : Int
    var int_requested : Bool
    
    init(pins: Pins, port: UInt8) {
        self.port = port
        self.pins = pins
        t_cycle = 0
        int_requested = false
    }
    
    func read() -> UInt8? {
        print("read!")
        return 0x01
    }
    
    func write(data: UInt8) -> Bool {
        print("write \(data)!")
        return true
    }
    
    func irq() -> Bool {
        return false
    }
}
