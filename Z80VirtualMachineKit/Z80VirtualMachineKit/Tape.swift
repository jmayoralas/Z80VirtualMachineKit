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
    case sendingData
}

private enum EarLevel: Int {
    case off = 0
    case on = 1
}

private let kTStatesPerSecond = 3500000
private let kLeadingToneTStatesEdgeDuration = 2168
private let kLeadingToneTStatesDuration = kTStatesPerSecond * 4

final class Tape {
    let ula: Ula
    let loader: TapeLoader
    
    var tapeAvailable: Bool = false
    var isPlaying: Bool = false
    private var status = TapeStatus.idle
    
    private var lastLevel = EarLevel.off
    
    private var tCycle: Int = 0
    private var tCyclesTone: Int = 0
    
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
        self.tCyclesTone += tCycle
        
        switch self.status {
        case .idle:
            sendLeadingTone()
            
        case .sendingLeadingTone:
            sendLeadingTone()
            
        case .sendingData:
            break
        }
    }
    
    func sendLeadingTone() {
        // this is invoked only with values .idle or .sendingLeadingTone in status
        // no need for checking any other statuses
        if self.status == .idle {
            self.status = .sendingLeadingTone
            self.lastLevel = .on
            self.ula.setTapeLevel(value: self.lastLevel.rawValue)
        } else {
            if self.tCyclesTone >= kLeadingToneTStatesDuration {
                self.status = .sendingData
                self.tCycle = 0
                self.tCyclesTone = 0
            } else {
                switch self.lastLevel {
                case .off:
                    if self.tCycle >= kLeadingToneTStatesEdgeDuration {
                        self.lastLevel = .on
                        self.ula.setTapeLevel(value: self.lastLevel.rawValue)
                        self.tCycle -= kLeadingToneTStatesEdgeDuration
                    }
                    
                case .on:
                    if self.tCycle >= kLeadingToneTStatesEdgeDuration {
                        self.lastLevel = .off
                        self.ula.setTapeLevel(value: self.lastLevel.rawValue)
                        self.tCycle -= kLeadingToneTStatesEdgeDuration
                    }
                }
            }
            
        }
    }
    
}
