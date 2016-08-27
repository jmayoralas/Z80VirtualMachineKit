//
//  Tape.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 26/8/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation

private enum TapeStatus {
    case idle
    case sendingLeadingTone
}

private enum EarLevel: Int {
    case off = 0
    case on = 1
}

private let kEarOnTStates = 2168
private let kEarOffTStates = 2168

final class Tape {
    let ula: Ula
    let loader: TapeLoader
    
    var tapeAvailable: Bool = false
    var isPlaying: Bool = false
    private var status = TapeStatus.idle
    
    private var lastLevel = EarLevel.off
    
    private var tCycle: Int = 0
    
    init(ula: Ula) {
        self.ula = ula
        self.loader = TapeLoader()
    }
    
    func open(path: String) throws {
        if self.tapeAvailable {
            loader.close()
            self.tapeAvailable = false
        }
        
        try loader.open(path: path)
        self.tapeAvailable = true
    }
    
    func close() {
        self.loader.close()
        self.tapeAvailable = false
    }
    
    func blockRequested() throws -> [UInt8]? {
        var tapeBlock: TapeBlock?
        
        tapeBlock = try loader.readBlock()
        
        var data: [UInt8]? = nil
        
        if let block = tapeBlock {
            data = block.data
        }
        
        return data
    }
    
    func play() throws {
        guard self.tapeAvailable else {
            throw TapeLoaderErrors.NoTapeOpened
        }
        
        self.isPlaying = true
    }
    
    func stop() {
        self.isPlaying = false
    }
    
    func step(tCycle: Int) {
        guard self.isPlaying else {
            return
        }
        
        self.tCycle += tCycle
        
        switch self.status {
        case .idle:
            sendLeadingTone()
            
        case .sendingLeadingTone:
            sendLeadingTone()
        }
    }
    
    func sendLeadingTone() {
        // this is invoked only with values .idle or .sendingLeadingTone in status
        // no need for checking any other statuses
        if self.status == .idle {
            self.status = .sendingLeadingTone
            self.lastLevel = .on
            self.ula.setEarLevel(value: self.lastLevel.rawValue)
        } else {
            switch self.lastLevel {
            case .off:
                if self.tCycle >= kEarOffTStates {
                    self.lastLevel = .on
                    self.ula.setEarLevel(value: self.lastLevel.rawValue)
                    self.tCycle -= kEarOffTStates
                }
                
            case .on:
                if self.tCycle >= kEarOnTStates {
                    self.lastLevel = .off
                    self.ula.setEarLevel(value: self.lastLevel.rawValue)
                    self.tCycle -= kEarOnTStates
                }
            }
        }
    }
    
}
