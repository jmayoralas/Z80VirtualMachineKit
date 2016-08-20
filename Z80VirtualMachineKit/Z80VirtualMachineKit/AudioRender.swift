//
//  CoreAudio.swift
//  Z80VirtualMachineKit
//
//  Created by Jose Luis Fernandez-Mayoralas on 17/8/16.
//  Copyright © 2016 lomocorp. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

class AudioRender {
    private let ioUnit: AUAudioUnit
    private let soundWave: SoundWave
    private var started: Bool = false
    
    init(soundWave: SoundWave) {
        let ioUnitDesc = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_HALOutput,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        
        ioUnit = try! AUAudioUnit(componentDescription: ioUnitDesc, options: AudioComponentInstantiationOptions())
        
        let hardwareFormat = ioUnit.outputBusses[0].format
        let renderFormat = AVAudioFormat(standardFormatWithSampleRate: hardwareFormat.sampleRate, channels: min(1, hardwareFormat.channelCount))
        
        try! ioUnit.inputBusses[0].setFormat(renderFormat)
        
        self.soundWave = soundWave
        
        ioUnit.outputProvider = { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, timestamp: UnsafePointer<AudioTimeStamp>, frameCount: AUAudioFrameCount, busIndex: Int, rawBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus in
            
            let bufferList = UnsafeMutableAudioBufferListPointer(rawBufferList)
            if bufferList.count > 0 {
                soundWave.render(buffer: bufferList[0])
            }
            
            return noErr
        }
    }
    
    func start() {
        try! self.ioUnit.allocateRenderResources()
        try! self.ioUnit.startHardware()
        
        started = true
    }
    
    func isStarted() -> Bool {
        return self.started
    }
}
