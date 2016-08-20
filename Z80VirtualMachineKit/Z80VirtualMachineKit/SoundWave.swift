//
//  SoundWave.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 25/7/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation
import BlipBuffer

private let TICS_PER_LINE = 224
private let SCREEN_LINES = 312 // 64 + 192 + 56
private let TICS_PER_FRAME = TICS_PER_LINE * SCREEN_LINES

private let kProcessorSpeed = 3500000 // hz
private let kAmplTape: Int32 = 2 * 256
private let kAmplBeeper: Int32 = 50 * 256
private let _kSampleRate = 48000

private let hz = kProcessorSpeed / TICS_PER_FRAME
private let sound_frame_size = _kSampleRate / hz + 1

typealias BlipSynthRef = UnsafeMutablePointer<Blip_Synth>
typealias BlipBufferRef = UnsafeMutablePointer<Blip_Buffer>
typealias BlipSampleRef = UnsafeMutablePointer<blip_sample_t>

protocol SoundWaveDelegate {
    func audioDataRequested()
}

class SoundWave {
    private let beeper_ampl: [Int32] = [0, kAmplTape, kAmplBeeper, kAmplTape + kAmplBeeper]
    private var synthRef: BlipSynthRef
    private var bufferRef: BlipBufferRef
    
    private var samples = [Int16]()
    
    init() {
        bufferRef = new_Blip_Buffer()
        
        blip_buffer_set_clock_rate(bufferRef, kProcessorSpeed)
        blip_buffer_set_sample_rate(bufferRef, _kSampleRate, 1000)
        
        synthRef = new_Blip_Synth()
        
        blip_synth_set_volume(synthRef, 100)
        blip_synth_set_output(synthRef, bufferRef)
        
        blip_buffer_set_bass_freq(bufferRef, 0)
        blip_synth_set_treble_eq(synthRef, 0)
    }
    
    func soundBeeper(t_cycle: Int, value: UInt8) {
        var on = ( (value & 0x10) > 0 ? 2 : 0 ) + ( (value & 0x08) > 0 ? 0 : 1 )
        let amp = beeper_ampl[on]
        
        blip_synth_update(synthRef, blip_time_t(t_cycle), amp)
    }
    
    func endFrame() {
        blip_buffer_end_frame(bufferRef, TICS_PER_FRAME)
        
        let samplesRef: BlipSampleRef = BlipSampleRef.allocate(capacity: sound_frame_size)
        let count = blip_buffer_read_samples(bufferRef, samplesRef, sound_frame_size, 0)
        
        self.samples = Array(UnsafeBufferPointer(start: samplesRef, count: count))
    }    
}
