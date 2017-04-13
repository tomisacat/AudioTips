//: Playground - noun: a place where people can play

import UIKit
import AudioToolbox

// function

func openFile() -> ExtAudioFileRef? {
    let url = Bundle.main.url(forResource: "guitar", withExtension: "m4a")
    var fd: ExtAudioFileRef? = nil
    ExtAudioFileOpenURL(url! as CFURL, &fd)
    
    return fd
}

func closeFile(fd: ExtAudioFileRef) {
    ExtAudioFileDispose(fd)
}

func openFileWithWritePermission() -> ExtAudioFileRef? {
    let url = URL(fileURLWithPath: "sound.m4a",
                  isDirectory: false,
                  relativeTo: URL(fileURLWithPath: NSTemporaryDirectory(),
                                  isDirectory: true))
    var fd: ExtAudioFileRef? = nil
    
    // WARNING: arbitrary parameter value, do NOT use directly
    var asbd: AudioStreamBasicDescription = AudioStreamBasicDescription(mSampleRate: 44100,
                                                                        mFormatID: kAudioFormatMPEG4AAC,
                                                                        mFormatFlags: kAudioFormatFlagIsFloat,
                                                                        mBytesPerPacket: 1000,
                                                                        mFramesPerPacket: 2,
                                                                        mBytesPerFrame: 1000,
                                                                        mChannelsPerFrame: 2,
                                                                        mBitsPerChannel: 2000,
                                                                        mReserved: 0)
    
    var acl: AudioChannelLayout = AudioChannelLayout()
    ExtAudioFileCreateWithURL(url as CFURL, kAudioFileM4AType, &asbd, &acl, AudioFileFlags.eraseFile.rawValue, &fd)
    
    return fd
}

// use

let fd = openFile()
if let fd = fd {
    print("succeed to open file")
    
    closeFile(fd: fd)
}

let fd2 = openFileWithWritePermission()
if let fd2 = fd2 {
    print("succeed to open file with write permission")
    
    closeFile(fd: fd2)
}