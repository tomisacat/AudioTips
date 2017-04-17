//: Playground - noun: a place where people can play

import UIKit
import AudioToolbox

func audioFileStream_PropertyListenerProc(inclientData: UnsafeMutableRawPointer,
                                          inAudioFileStream: AudioFileStreamID,
                                          inPropertyID: AudioFileStreamPropertyID,
                                          ioFlags: UnsafeMutablePointer<AudioFileStreamPropertyFlags>) {
    print("inClientData: \(inclientData.advanced(by: 0)), \(Thread.current) - property listener with flags: \(ioFlags.pointee)")
}

func audioFileStream_PacketsProc(inClientData: UnsafeMutableRawPointer,
                                 inNumberBytes: UInt32,
                                 inNumberPackets: UInt32,
                                 inInputData: UnsafeRawPointer,
                                 inPacketDescription: UnsafeMutablePointer<AudioStreamPacketDescription>) {
    print("inClientData: \(inClientData.advanced(by: 0)), \(Thread.current) - packets with \(inNumberPackets) packets, \(inNumberBytes) bytes")
}

var audioFileStream: AudioFileStreamID? = nil
let inClientData: UnsafeMutableRawPointer? = UnsafeMutableRawPointer(bitPattern: 1)
var status: OSStatus = AudioFileStreamOpen(inClientData,
                                           audioFileStream_PropertyListenerProc,
                                           audioFileStream_PacketsProc,
                                           0,
                                           &audioFileStream)

if status == noErr, let audioFileStream = audioFileStream {
    print("succeed")
    
//    guard let path = Bundle.main.path(forResource: "01", ofType: "caf") else {
//        return
//    }
//    
//    guard let fileHandle = FileHandle(forReadingAtPath: path) else {
//        return
//    }
    
    // It's strange that it will NOT work on an m4a audio file, will try to find the reason.
    if let path = Bundle.main.path(forResource: "01", ofType: "caf"),
        let fileHandle = FileHandle(forReadingAtPath: path) {
        
        repeat {
            let data = fileHandle.readData(ofLength: 1024) as NSData
            if data.length > 0 {
                print("\(Thread.current) have read \(data.length)")
                
                status = AudioFileStreamParseBytes(audioFileStream,
                                                   UInt32(data.length),
                                                   data.bytes,
                                                   AudioFileStreamParseFlags(rawValue: 0))
//                    status = AudioFileStreamParseBytes(audioFileStream, UInt32(data.length), data.bytes, .discontinuity)
                if status == noErr {
                    print("parse succeed")
                }
            } else {
                print("read EOF")
                break
            }
        } while true
    }
}
