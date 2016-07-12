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
let kNumberBuffers = 3
let kNumberBufferElements = Int(kSampleRate) / 50

extension Int {
    var degreesToRadian: Double {
        return Double(self) * .pi / 180
    }
}

class AudioStreamer {
    var outputQueue: AudioQueueRef?
    
    var buffers = [AudioQueueBufferRef?](repeatElement(nil, count: kNumberBuffers))
    let bufferByteSize = UInt32(kNumberBufferElements * sizeof(AudioDataElement)) // 20 mili sec of audio
    
    var allocatedBuffers = 0
    
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
    
    init() {
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
    }
    
    var audioData: AudioData? {
        get {
            return self.audioData
        }
        
        set {
            self.audioData = newValue
            
            if let _ = self.audioData {
                // if there are still free buffers, allocate buffer and prime this audioData to outputQueue
                if self.allocatedBuffers < kNumberBufferElements {
                    AudioQueueAllocateBuffer(
                        self.outputQueue!,
                        self.bufferByteSize,
                        &self.buffers[self.allocatedBuffers]
                    )
                    
                    if let bufferRef = self.buffers[self.allocatedBuffers] {
                        // configure audio buffer
                        let selfPointer = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
                        
                        bufferRef.pointee.mUserData = selfPointer
                        bufferRef.pointee.mAudioDataByteSize = self.bufferByteSize
                        
                        self.allocatedBuffers += 1
                        
                        AudioStreamerOuputCallback(userData: selfPointer, queueRef: self.outputQueue!, buffer: self.buffers[self.allocatedBuffers]!)
                        
                        if self.allocatedBuffers == kNumberBufferElements {
                            // all buffers completed, outputQueue can be started now
                            AudioQueueStart(self.outputQueue!, nil)
                        }
                    }
                }
            }
        }
    }
}

func AudioStreamerOuputCallback(userData: Optional<UnsafeMutablePointer<Void>>, queueRef: AudioQueueRef, buffer: AudioQueueBufferRef) {
    // recover AudioStreamer instance from void * userData
    let this = Unmanaged<AudioStreamer>.fromOpaque(OpaquePointer(userData!)).takeUnretainedValue()
    
    if let audioData = this.audioData {
        memcpy(buffer.pointee.mAudioData, unsafeBitCast(audioData, to: UnsafeMutablePointer<Void>.self), Int(this.bufferByteSize))
        
        AudioQueueEnqueueBuffer(queueRef, buffer, 0, nil)
        this.audioData = nil
    } else {
        AudioQueueStop(queueRef, false)
    }
}
