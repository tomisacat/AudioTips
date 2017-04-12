//: Playground - noun: a place where people can play

import UIKit
import AudioToolbox

// function

func openFile() -> AudioFileID? {
    let url = Bundle.main.url(forResource: "guitar", withExtension: "m4a")
    var fd: AudioFileID? = nil
    AudioFileOpenURL(url! as CFURL, .readPermission, kAudioFileM4AType, &fd)
    
    // Or in iOS platform, the file type could be 0 directly
    // AudioFileOpenURL(url! as CFURL, .readPermission, 0, &fd)

    return fd
}

func closeFile(fd: AudioFileID) {
    AudioFileClose(fd)
}

// use

let fd: AudioFileID? = openFile()
if let fd = fd {
    Swift.print("open file succeed")
    
    // get bitRate
    var propertySize: UInt32 = 0
    var writable: UInt32 = 0
    var status = AudioFileGetPropertyInfo(fd, kAudioFilePropertyBitRate, &propertySize, &writable)
    if status == noErr {
        var bitRate: UInt32 = 0
        AudioFileGetProperty(fd, kAudioFilePropertyBitRate, &propertySize, &bitRate)
        print(bitRate)
    }
    
    
    
    // finally close file
    closeFile(fd: fd)
}
