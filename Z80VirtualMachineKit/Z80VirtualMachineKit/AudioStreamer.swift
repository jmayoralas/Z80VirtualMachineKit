//
//  AudioStreamer.swift
//  TestAudioQueue
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/7/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation
import AudioToolbox

let kTicsPerLine = 224
let kScreenLines = 312 // 64 + 192 + 56
let kTicsPerFrame = kTicsPerLine * kScreenLines

private let kSampleRate = 48000.0
private let kSamplesPerFrame = Int(kSampleRate) / 50
private let kNumberBuffers = 3

typealias AudioDataElement = Float
typealias AudioData = [AudioDataElement]

class AudioStreamer {
    
    private let soundLevel: [Double] = [0.0, 0.77/3.79, 3.66/3.79, 3.79/3.79];
    
    var outputQueue: AudioQueueRef?
    
    var buffers = [AudioQueueBufferRef?](repeatElement(nil, count: kNumberBuffers))
    let bufferByteSize = UInt32(kSamplesPerFrame * MemoryLayout<AudioDataElement>.size) // 20 mili sec of audio
    
    var nextAvailableBuffer = 0
    
    var streamBasicDescription = AudioStreamBasicDescription(
        mSampleRate: 48000.0,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagsNativeFloatPacked,
        mBytesPerPacket: UInt32(MemoryLayout<AudioDataElement>.size),
        mFramesPerPacket: 1,
        mBytesPerFrame: UInt32(MemoryLayout<AudioDataElement>.size),
        mChannelsPerFrame: 1,
        mBitsPerChannel: UInt32(8 * MemoryLayout<AudioDataElement>.size),
        mReserved: 0
    )
    
    private var audioData: AudioData!
    private var sample: AudioDataElement = 0
    private var dcAverage: AudioDataElement = 0

    private let semaphore = DispatchSemaphore(value: 0)
    
    init() {
        self.audioData = AudioData(repeating: 0.0, count: kSamplesPerFrame)
        
        // create new output audio queue
        AudioQueueNewOutput(
            &self.streamBasicDescription,
            AudioStreamerOuputCallback,
            unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self),
            nil,
            nil,
            0,
            &self.outputQueue
        )
        
        // allocate audio buffers
        for i in 0 ..< kNumberBuffers {
            AudioQueueAllocateBuffer(
                self.outputQueue!,
                self.bufferByteSize,
                &self.buffers[i]
            )
            
            if let bufferRef = self.buffers[i] {
                // configure audio buffer
                let selfPointer = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
    
                bufferRef.pointee.mUserData = selfPointer
                bufferRef.pointee.mAudioDataByteSize = self.bufferByteSize
                
                AudioStreamerOuputCallback(userData: selfPointer, queueRef: self.outputQueue!, buffer: bufferRef)
            }
        }
    }
    
    func start() {
        AudioQueueStart(self.outputQueue!, nil)
    }
    
    func updateSample(tCycle: Int, value: UInt8) {
        let on = ( (value & 0x10) > 0 ? 2 : 0 ) + ( (value & 0x08) > 0 ? 0 : 1 )
        let amplitude = Float(self.soundLevel[on])
        
        dcAverage = (dcAverage + amplitude) / 2
        
        sample -= sample / 8
        sample += amplitude / 8
        
        let offset: Int = (tCycle * kSamplesPerFrame) / kTicsPerFrame;
        if offset < kSamplesPerFrame {
            audioData[offset] = sample - dcAverage
        }
    }
    
    func clearAudioData() {
//        self.audioData = AudioData(repeating: 0.0, count: kSamplesPerFrame)
        self.semaphore.signal()
    }
    
    func getAudioData() -> AudioData {
        return self.audioData
    }
    
    func endFrame() {
        self.semaphore.wait()
    }
}

private func AudioStreamerOuputCallback(userData: Optional<UnsafeMutableRawPointer>, queueRef: AudioQueueRef, buffer: AudioQueueBufferRef) {
    // recover AudioStreamer instance from void * userData
    let this = Unmanaged<AudioStreamer>.fromOpaque(userData!).takeUnretainedValue()
    
    let audioData = this.getAudioData()
    memcpy(buffer.pointee.mAudioData, unsafeBitCast(audioData, to: UnsafeMutablePointer<Void>.self), Int(this.bufferByteSize))
    
    AudioQueueEnqueueBuffer(queueRef, buffer, 0, nil)
    this.clearAudioData()
}
