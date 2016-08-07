//
//  AudioStreamer.swift
//  TestAudioQueue
//
//  Created by Jose Luis Fernandez-Mayoralas on 11/7/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Foundation
import AudioToolbox

typealias AudioDataElement = Float
typealias AudioData = [AudioDataElement]

let kSampleRate = 48000.0
let kSamplesPerFrame = Int(kSampleRate) / 50
let kNumberBuffers = 3


protocol AudioStreamerDelegate {
    func requestAudioData(sender: AudioStreamer) -> AudioData
}

class AudioStreamer {
    var audioData: AudioData?
    
    var delegate: AudioStreamerDelegate
    var outputQueue: AudioQueueRef?
    
    var buffers = [AudioQueueBufferRef?](repeatElement(nil, count: kNumberBuffers))
    let bufferByteSize = UInt32(kSamplesPerFrame * sizeof(AudioDataElement)) // 20 mili sec of audio
    
    var nextAvailableBuffer = 0
    
    var streamBasicDescription = AudioStreamBasicDescription(
        mSampleRate: 48000.0,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagsNativeFloatPacked,
        mBytesPerPacket: UInt32(sizeof(AudioDataElement)),
        mFramesPerPacket: 1,
        mBytesPerFrame: UInt32(sizeof(AudioDataElement)),
        mChannelsPerFrame: 1,
        mBitsPerChannel: UInt32(8 * sizeof(AudioDataElement)),
        mReserved: 0
    )
    
    init(delegate: AudioStreamerDelegate) {
        self.delegate = delegate
        
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
                let selfPointer = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
    
                bufferRef.pointee.mUserData = selfPointer
                bufferRef.pointee.mAudioDataByteSize = self.bufferByteSize
                
                AudioStreamerOuputCallback(userData: selfPointer, queueRef: self.outputQueue!, buffer: bufferRef)
            }
        }
    }
    
    func start() {
        AudioQueueStart(self.outputQueue!, nil)
    }
    
    func enqueueAudioData(_ audioData: AudioData) {
        // wait for a free audioData buffer
        self.audioData = audioData
        NSLog("new audioData")
        
        if self.nextAvailableBuffer < kNumberBuffers {
            let selfPointer = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
            AudioStreamerOuputCallback(userData: selfPointer, queueRef: self.outputQueue!, buffer: self.buffers[nextAvailableBuffer]!)
            self.nextAvailableBuffer += 1
            
            if self.nextAvailableBuffer == kNumberBuffers {
                AudioQueueStart(self.outputQueue!, nil)
            }
        }
    }
}

func AudioStreamerOuputCallback(userData: Optional<UnsafeMutablePointer<Void>>, queueRef: AudioQueueRef, buffer: AudioQueueBufferRef) {
    // recover AudioStreamer instance from void * userData
    let this = Unmanaged<AudioStreamer>.fromOpaque(userData!).takeUnretainedValue()
    
    let audioData = this.delegate.requestAudioData(sender: this)
    memcpy(buffer.pointee.mAudioData, unsafeBitCast(audioData, to: UnsafeMutablePointer<Void>.self), Int(this.bufferByteSize))
    
    AudioQueueEnqueueBuffer(queueRef, buffer, 0, nil)
    this.audioData = nil
}
