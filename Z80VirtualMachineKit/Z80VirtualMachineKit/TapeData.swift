//
//  NSData+TapeLoader.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 26/8/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation

private enum TzxBlockId: UInt8 {
    case StandardSpeed = 0x10
    case DirectRecording = 0x15
    case PauseOrStopTape = 0x20
    case GroupStart = 0x21
    case TextDescription = 0x30
    case ArchiveInfo = 0x32
}

final class TapeData {

    private var data: NSData

    var length: Int {
        get {
            return self.data.length
        }
    }
    
    init?(contentsOfFile path: String) {
        guard let data = NSData(contentsOfFile: path) else {
            return nil
        }
        
        self.data = data
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tapeFormat: TapeFormat {
        get {
            // get first 8 bytes and search for TZX signature
            let range = NSRange(location: 0, length: 7)
            var tapeFormat: TapeFormat = .Tap
            
            var signatureBytes = [UInt8](repeating: 0, count: 7)
            self.data.getBytes(&signatureBytes, range: range)
            
            if let signature = String(bytes: signatureBytes, encoding: String.Encoding.utf8) {
                if signature == "ZXTape!" {
                    tapeFormat = .Tzx
                }
            }
            
            return tapeFormat
        }
    }
    
    // MARK: Public methods
    func getLocationFirstTapeDataBlock() -> Int {
        var firstDataBlock: Int = 0
        
        switch tapeFormat {
        case .Tap:
            firstDataBlock = 0
        case .Tzx:
            firstDataBlock = 10
        }
        
        return firstDataBlock
        
    }
    
    func getTapeBlock(atLocation location: Int) throws -> TapeBlock {
        let tapeBlock: TapeBlock
        
        switch self.tapeFormat {
        case .Tap:
            tapeBlock = self.getTapTapeBlock(atLocation: location)
        case .Tzx:
            tapeBlock = try self.getTzxTapeBlock(atLocation: location)
        }
        
        return tapeBlock
    }
    
    // MARK: Private methods
    private func getNumber(location: Int, size: Int) -> Int {
        var number: Int = 0
        
        let range = NSRange(location: location, length: size)
        var bytes = [UInt8](repeatElement(0, count: size))
        
        self.data.getBytes(&bytes, range: range)
        
        for i in (0 ..< size).reversed() {
            number += Int(bytes[i]) << (8 * i)
        }
        
        return number
    }
    
    private func getBytes(location: Int, size: Int) -> [UInt8] {
        let range = NSRange(location: location, length: Int(size))
        var data = [UInt8](repeating: 0, count: Int(size))
        self.data.getBytes(&data, range: range)
        
        return data
    }
    
    private func getTapTapeBlock(atLocation location: Int) -> TapeBlock {
        let size = self.getNumber(location: location, size: 2)
        let data = self.getBytes(location: location + 2, size: size)
        
        return self.getTapTapeBlock(data: data)
    }
    
    private func getTapTapeBlock(data: [UInt8]) -> TapeBlock {
        let identifier: String
        let tapeBlockTimingInfo: TapeBlockTimingInfo
        let type: TapeBlockType
        
        if data[0] == 0x00 {
            let name : [UInt8] = Array(data[2...11])
            identifier = String(data: Data(name), encoding: String.Encoding.ascii)!
            tapeBlockTimingInfo = kTapeBlockTimingInfoStandardROMHeader
            if let typeFromData = TapeBlockType(rawValue: Int(data[1])) {
                type = typeFromData
            } else {
                type = .Dummy
            }
        } else {
            identifier = "[DATA]"
            tapeBlockTimingInfo = kTapeBlockTimingInfoStandardROMData
            type = .Dummy
        }
        
        return TapeBlock(size: data.count + 2, info: tapeBlockTimingInfo, identifier: identifier, type: type, data: data)
    }

    private func getTzxTapeBlock(atLocation location: Int) throws -> TapeBlock {
        let blockIdValue = UInt8(self.getNumber(location: location, size: 1))
        
        guard let blockId = TzxBlockId(rawValue: blockIdValue) else {
            throw TapeLoaderError.UnsupportedTapeBlockFormat(blockId: blockIdValue, location: location)
        }
        
        return try self.getTzxTapeBlock(blockId: blockId, location: location + 1)
    }
    
    private func getTzxTapeBlock(blockId: TzxBlockId, location: Int) throws -> TapeBlock {
        var block: TapeBlock
        
        switch blockId {
        case .StandardSpeed:
            let pause = self.getNumber(location: location, size: 2)
            
            block = self.getTapTapeBlock(atLocation: location + 2)
        
            block.size += 3
            if pause > 0 {
                block.timingInfo.pauseAfterBlock = pause
            }
            
        case .DirectRecording:
            let size = self.getNumber(location: location + 6, size: 1)
            guard size == 0 else {
                throw TapeLoaderError.UnsupportedTapeBlockFormat(blockId: blockId.rawValue, location: location - 1)
            }
            
            block = TapeBlock(size: size + 10)
            
        case .ArchiveInfo:
            let size = self.getNumber(location: location, size: 2)
            block = TapeBlock(size: size + 3)
            
        case .PauseOrStopTape:
            let pause = self.getNumber(location: location, size: 2)
            block = TapeBlock(size: 3)
            block.timingInfo.pauseAfterBlock = pause
            block.identifier = kPauseTapeBlockIdentifier
            
        case .TextDescription:
            let size = self.getNumber(location: location, size: 1)
            block = TapeBlock(size: size + 2)
            
        case .GroupStart:
            let size = self.getNumber(location: location, size: 1)
            block = TapeBlock(size: size + 2)
        }
        
        return block
    }
}
