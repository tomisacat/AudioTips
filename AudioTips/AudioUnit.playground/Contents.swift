//: Playground - noun: a place where people can play

import UIKit
import AudioToolbox
import AVFoundation

@discardableResult
func setupAudioSession() -> Bool {
    do {
        try AVAudioSession.sharedInstance().setActive(true)
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        return true
    } catch {
        return false
    }
}

var graph: AUGraph?
var remoteIONode: AUNode = 0
var remoteIOUnit: AudioUnit?
var remoteIODesc: AudioComponentDescription?

func buildAUGraph() {
    // create graph
    if NewAUGraph(&graph) != noErr {
        return
    }
    
    // component description
    remoteIODesc = AudioComponentDescription(componentType: kAudioUnitType_Output,
                                             componentSubType: kAudioUnitSubType_RemoteIO,
                                             componentManufacturer: kAudioUnitManufacturer_Apple,
                                             componentFlags: 0,
                                             componentFlagsMask: 0)
    
    ////////////////////
    // 1. get audio unit through AudioComponentInstanceNew function
    
    // get component according to the description
    guard let component = AudioComponentFindNext(nil, &remoteIODesc!) else {
        return
    }
    //        repeat {
    //            print(component ?? "no component")
    //            component = AudioComponentFindNext(component, &remoteIODesc!)
    //         } while component != nil
    var componentInstance: AudioComponentInstance?
    if AudioComponentInstanceNew(component, &componentInstance) != noErr {
        return
    }
    
    /////////////////////
    // 2. get audio unit through AUGraph
    
    // node
    if AUGraphAddNode(graph!, &remoteIODesc!, &remoteIONode) != noErr {
        return
    }
    
    // open graph
    if AUGraphOpen(graph!) != noErr {
        return
    }
    
    // get audio unit(component) through node information
    if AUGraphNodeInfo(graph!, remoteIONode, nil, &remoteIOUnit) != noErr {
        return
    }
    
    // set enable IO
    var one: UInt32 = 0
    if AudioUnitSetProperty(remoteIOUnit!,
                            kAudioOutputUnitProperty_EnableIO,
                            kAudioUnitScope_Input,
                            1,
                            &one,
                            UInt32(MemoryLayout<UInt32>.size)) != noErr {
        return
    }
    
    if AudioUnitSetProperty(remoteIOUnit!,
                            kAudioOutputUnitProperty_EnableIO,
                            kAudioUnitScope_Output,
                            0,
                            &one,
                            UInt32(MemoryLayout<UInt32>.size)) != noErr {
        return
    }
    
    // set format
    var format: AudioStreamBasicDescription = AudioStreamBasicDescription()
    format.mFormatID = kAudioFormatLinearPCM
    format.mBitsPerChannel = 16
    format.mChannelsPerFrame = 2
    format.mSampleRate = 44100.0
    format.mFramesPerPacket = 1
    format.mBytesPerFrame = format.mBitsPerChannel * format.mChannelsPerFrame / 8
    format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket
    var inFormat = format
    let status = AudioUnitSetProperty(remoteIOUnit!,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Output,
                                      0,
                                      &inFormat,
                                      UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
    if status != noErr {
        print(status)
    }
    
    var outFormat = format
    if AudioUnitSetProperty(remoteIOUnit!,
                            kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input,
                            0,
                            &outFormat,
                            UInt32(MemoryLayout<AudioStreamBasicDescription>.size)) != noErr {
        return
    }
}

// use

if setupAudioSession() == true {
    buildAUGraph()
}
