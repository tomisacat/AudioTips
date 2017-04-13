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
    
    // max packet size
    var packetSize: UInt32 = 0
    var maxPacketSize: UInt32 = 0
    status = AudioFileGetPropertyInfo(fd, kAudioFilePropertyMaximumPacketSize, &packetSize, &writable)
    if status == noErr {
        status = AudioFileGetProperty(fd, kAudioFilePropertyMaximumPacketSize, &packetSize, &maxPacketSize)
        if status == noErr {
            print("max packet size: \(maxPacketSize)")
        }
    }
    
    // packet count
    var packetCountSize: UInt32 = 0
    var packetCount: UInt32 = 0
    status = AudioFileGetPropertyInfo(fd, kAudioFilePropertyAudioDataPacketCount, &packetCountSize, &writable)
    if status == noErr {
        status = AudioFileGetProperty(fd, kAudioFilePropertyAudioDataPacketCount, &packetCountSize, &packetCount)
        if status == noErr {
            print("packet count: \(packetCount)")
        }
    }
    
    // read bytes
    var bytesToRead: UInt32 = 16
    var bytes: UInt64 = 0
    status = AudioFileReadBytes(fd, false, 0, &bytesToRead, &bytes)
    if status == noErr {
        print("\(bytesToRead) bytes read")
    }
    
    // read packet
    let packetBuffer: UnsafeMutablePointer<CChar> = UnsafeMutablePointer<CChar>.allocate(capacity: Int(maxPacketSize * 2) / MemoryLayout<CChar>.size)
    for idx in stride(from: 0, to: packetCount, by: 2) {
        let aspd: UnsafeMutablePointer<AudioStreamPacketDescription> = UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: 2)
        var pktNum: UInt32 = 2
        var packetBufferLength: UInt32 = maxPacketSize * 2
        if idx + 2 > packetCount {
            pktNum = 1
        }
        status = AudioFileReadPacketData(fd, false, &(packetBufferLength), aspd, Int64(idx), &pktNum, packetBuffer)
        if status == kAudioFileEndOfFileError {
            break
        }
        print("\(idx): \n \(aspd[0])\n \(aspd[1])\n packetBufferLength: \(packetBufferLength)\n pktNum: \(pktNum)\n---------")
    }
    
    // finally close file
    closeFile(fd: fd)
}
