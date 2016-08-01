//
//  AudioUnitStreamer.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 23/7/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation
import AudioUnit
import SFifo

protocol AudioUnitStreamerDelegate {
    func requestedAudioData()
}

class AudioUnitStreamer {
    var deviceFormat: AudioStreamBasicDescription!
    var gOutputUnit: AudioUnit?
    var audioOutputStarted: Bool = false
    var delegate: AudioUnitStreamerDelegate
    
    let bufferByteSize = UInt32(kSamplesPerFrame * sizeof(AudioDataElement)) // 20 mili sec of audio
    
    var soundFifo = sfifo_t()
    let soundFrameSize: Int32
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    init(sampleRate: Double, soundFrameSize: Int32, delegate: AudioUnitStreamerDelegate) {
        self.delegate = delegate
        self.soundFrameSize = soundFrameSize
        
        deviceFormat = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsPacked,
            mBytesPerPacket: 2,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )
        
        var err: OSStatus = kAudioHardwareNoError
        var device: AudioDeviceID = kAudioObjectUnknown
        
        getDefaultOutputDevice(&device)
        // getDefaultSampleRate(device: device, rate: &deviceFormat.mSampleRate)
        
        var desc = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_DefaultOutput,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        
        var comp = AudioComponentFindNext(nil, &desc)
        
        AudioComponentInstanceNew(comp!, &gOutputUnit)
        
        var input = AURenderCallbackStruct(inputProc: coreAudioWrite, inputProcRefCon: unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self))
        
        AudioUnitSetProperty(
            gOutputUnit!,
            kAudioUnitProperty_SetRenderCallback,
            kAudioUnitScope_Input,
            0,
            &input,
            UInt32(sizeof(AURenderCallbackStruct))
        )
        
        AudioUnitSetProperty(
            gOutputUnit!,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input,
            0,
            &deviceFormat,
            UInt32(sizeof(AudioStreamBasicDescription))
        )
        
        AudioUnitInitialize(gOutputUnit!)
        
        sfifo_init(&soundFifo, 2 * Int32(deviceFormat.mBytesPerFrame) * Int32(deviceFormat.mChannelsPerFrame) * self.soundFrameSize + 1)
        
        NSLog("sfifo_space: %d", sfifo_space(&soundFifo))
    }
    
    /* get the default output device for the HAL */
    private func getDefaultOutputDevice(_ device: UnsafeMutablePointer<AudioDeviceID>) {
        var property_address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster
        )
        
        var count = UInt32(sizeof(AudioDeviceID))
        
        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &property_address,
            0,
            nil,
            &count,
            device
        )
    }
 
    private func getDefaultSampleRate(device: AudioDeviceID, rate: UnsafeMutablePointer<Float64>) {
        var property_address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyNominalSampleRate,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster
        )
        
        var count = UInt32(sizeof(Float64))
        
        AudioObjectGetPropertyData(
            device,
            &property_address,
            0,
            nil,
            &count,
            rate
        )
    }
    
    public func soundFrame(data: UnsafeMutablePointer<Int16>, len: Int32) {
        var i: Int32 = 0
        
        var bytes = unsafeBitCast(data, to: UnsafeMutablePointer<UInt8>.self)
        
        var count = len << 1
        
        NSLog("%d", sfifo_space(&soundFifo))
        if sfifo_space(&soundFifo) < soundFrameSize {
            semaphore.wait()
        }
        while count > 0 {
            i = sfifo_write(&soundFifo, bytes, count)
            if i < 0 {
                break
            } else if i == 0 {
                usleep(10000)
            }
            
            bytes = bytes.advanced(by: Int(i))
            count -= i
        }
        
        if !audioOutputStarted {
            AudioOutputUnitStart(gOutputUnit!)
            
            audioOutputStarted = true
        }
    }
}

func coreAudioWrite(
    inRefCon: UnsafeMutablePointer<Void>,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp: UnsafePointer<AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    
    var bufferRef = UnsafeMutablePointer<AudioBuffer>(ioData!.pointee.mBuffers.mData)
    
    let this = Unmanaged<AudioUnitStreamer>.fromOpaque(inRefCon).takeUnretainedValue()
    
    var len: UInt32 = this.deviceFormat.mBytesPerFrame * inNumberFrames
    var out = unsafeBitCast(bufferRef, to: UnsafeMutablePointer<UInt8>.self)
    let sfifoUsed = UInt32(sfifo_used(&this.soundFifo))
    len = len < sfifoUsed ? len : sfifoUsed
    len &= 0xFFFE
    
    var f: Int32 = 0
    repeat {
        f = sfifo_read(&this.soundFifo, out, Int32(len))
        
        out = out.advanced(by: Int(f))
        len -= UInt32(f)
    } while f > 0
    
    if f < 0 {
        for _ in 0 ..< len {
            out.pointee = 0
            out = out.advanced(by: 1)
        }
    }
    
    if sfifo_space(&this.soundFifo) >= this.soundFrameSize {
        this.semaphore.signal()
    }
    
    return noErr
}
