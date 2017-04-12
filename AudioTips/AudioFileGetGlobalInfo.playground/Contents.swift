//: Playground - noun: a place where people can play

import UIKit
import AudioToolbox

// Returns a CFArray of CFString of all MIME types

// 1. get property size
var infoSize: UInt32 = 0
var status: OSStatus = AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_AllMIMETypes,
                                                  0,
                                                  nil,
                                                  &infoSize)
Swift.print("status: \(status), infoSize: \(infoSize)")

// 2. get property
var mimes: NSArray = [] as NSArray
status = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AllMIMETypes,
                                0,
                                nil,
                                &infoSize,
                                &mimes)
Swift.print("status: \(status), mimes: \(mimes)")

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

// Returns an array of UInt32 containing the file types

// 1. get property size
let readOrWrite = kAudioFileGlobalInfo_ReadableTypes
var propertySize: UInt32 = 0
status = AudioFileGetGlobalInfoSize(readOrWrite,
                                    0,
                                    nil,
                                    &propertySize)
// 2. get property
let types: UnsafeMutablePointer<OSType> = UnsafeMutablePointer<OSType>.allocate(capacity: Int(propertySize))
status = AudioFileGetGlobalInfo(readOrWrite,
                                0,
                                nil,
                                &propertySize,
                                types)
let count = Int(propertySize) / MemoryLayout<OSType>.size
// 3. print property items
for idx in 0..<count {
    // 4. Returns a CFString containing the name for the file type.
    
    var name: NSString? = nil
    var outSize: UInt32 = UInt32(MemoryLayout<NSString>.size)
    status = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_FileTypeName,
                                    UInt32(MemoryLayout<OSType>.size),
                                    types.advanced(by: idx),
                                    &outSize,
                                    &name)
    Swift.print(name ?? "")
}

// Conclusion:
// 1. Choose different generic types based on the return value's type
// 2. there is toll-free bridging between CoreFoundation and Foundation types. For example: You should use `NSString` instead of `String` when get `kAudioFileGlobalInfo_FileTypeName`, otherwise you will get nothing with Swift types.

// Many thank to onevcat( https://onevcat.com ), he give me a lot help.

// Reference:
// http://swifter.tips/toll-free/
// https://gist.github.com/onevcat/cc72e6946e27fe9bec0edfd6adc5f9c1