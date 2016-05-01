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
    var int_requested : IrqKind? { get set }

    func read() -> UInt8?
    func write(data : UInt8) -> Bool
    func irq() -> IrqKind?
}


extension IODeviceProtocol {
    func clk() -> Void {
        t_cycle += 1
        
        if let irq_kind = int_requested {
            switch irq_kind {
            case .NMI:
                if pins.m1 {
                    pins.nmi = false
                    int_requested = nil
                }
                
                t_cycle = 0
            case .Soft:
                if pins.m1 && pins.iorq {
                    pins.int = false
                    pins.wait = true
                    
                    if let data = self.read() {
                        pins.data_bus = data
                        pins.wait = false
                        int_requested = nil
                    }
                } else {
                    t_cycle = 0
                }
            }
        } else {
            // test if cpu is talking to us
            if !pins.iorq || pins.address_bus.low != port {
                t_cycle = 0
                
                int_requested = irq()
                
                if let irq_kind = int_requested {
                    if irq_kind == .Soft {
                        pins.int = true
                    } else {
                        pins.nmi = true
                    }
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

public class IODevice : IODeviceProtocol {
    var port : UInt8
    var pins : Pins
    var t_cycle : Int
    var int_requested : IrqKind?
    
    init(pins: Pins, port: UInt8) {
        self.port = port
        self.pins = pins
        t_cycle = 0
        int_requested = nil
    }
    
    func read() -> UInt8? {
        print("read!")
        return 0x01
    }
    
    func write(data: UInt8) -> Bool {
        print("write \(data)!")
        return true
    }
    
    func irq() -> IrqKind? {
        return nil
    }
}
