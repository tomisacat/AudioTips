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
    
    // get bit rate
    var propertySize: UInt32 = 0
    var writable: UInt32 = 0
    var status = AudioFileGetPropertyInfo(fd, kAudioFilePropertyBitRate, &propertySize, &writable)
    if status == noErr {
        print("writable: \(writable)")
        var bitRate: UInt32 = 0
        AudioFileGetProperty(fd, kAudioFilePropertyBitRate, &propertySize, &bitRate)
        print(bitRate)
    }
    
    // format
    var formatSize: UInt32 = 0
    status = AudioFileGetPropertyInfo(fd, kAudioFilePropertyFileFormat, &formatSize, &writable)
    if status == noErr {
        var format: UnsafeMutablePointer<AudioFilePropertyID> = UnsafeMutablePointer<AudioFilePropertyID>.allocate(capacity: Int(formatSize) / MemoryLayout<AudioFilePropertyID>.size)
        status = AudioFileGetProperty(fd, kAudioFilePropertyFileFormat, &formatSize, &format)
        if status == noErr {
            var name: NSString? = nil
            var outSize: UInt32 = UInt32(MemoryLayout<NSString>.size)
            AudioFileGetGlobalInfo(kAudioFileGlobalInfo_FileTypeName, UInt32(MemoryLayout<AudioFilePropertyID>.size), &format, &outSize, &name)
            print(name ?? "")
        }
    }
    
    // read bytes
    var bytesToRead: UInt32 = 16
    var bytes: UInt64 = 0
    status = AudioFileReadBytes(fd, false, 0, &bytesToRead, &bytes)
    if status == noErr {
        print("\(bytesToRead) read")
    }
    
    
    // finally close file
    closeFile(fd: fd)
}
