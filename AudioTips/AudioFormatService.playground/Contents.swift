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
    var status: OSStatus = noErr
    var propertySize: UInt32 = 0
    var writable: UInt32 = 0
    
    // magic cookie
    status = AudioFileGetPropertyInfo(fd, kAudioFilePropertyMagicCookieData, &propertySize, &writable)
    
//    if status != noErr {
//        return
//    }
    
    let magic: UnsafeMutablePointer<CChar> = UnsafeMutablePointer<CChar>.allocate(capacity: Int(propertySize))
    status = AudioFileGetProperty(fd, kAudioFilePropertyMagicCookieData, &propertySize, magic)
    
//    if status != noErr {
//        return
//    }
    
    // format info in magic cookie data
    var desc: AudioStreamBasicDescription = AudioStreamBasicDescription()
    var descSize: UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
    status = AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, propertySize, magic, &descSize, &desc)
    
//    if status != noErr {
//        return
//    }
    
    print(desc)
    
    // format name
    status = AudioFileGetProperty(fd, kAudioFilePropertyDataFormat, &descSize, &desc)
    
//    if status != noErr {
//        return
//    }
    
    var formatName: CFString = String() as CFString
    var formatNameSize: UInt32 = UInt32(MemoryLayout<CFString>.size)
    status = AudioFormatGetProperty(kAudioFormatProperty_FormatName, descSize, &desc, &formatNameSize, &formatName)
    
//    if status != noErr {
//        return
//    }
    
    print(formatName)
    
    // format list
    var formatInfo: AudioFormatInfo = AudioFormatInfo(mASBD: desc,
                                                      mMagicCookie: magic,
                                                      mMagicCookieSize: propertySize)
    var outputFormatInfoSize: UInt32 = 0
    status = AudioFormatGetPropertyInfo(kAudioFormatProperty_FormatList,
                                        UInt32(MemoryLayout<AudioFormatInfo>.size),
                                        &formatInfo,
                                        &outputFormatInfoSize)
    let formatListItem: UnsafeMutablePointer<AudioFormatListItem> = UnsafeMutablePointer<AudioFormatListItem>.allocate(capacity: Int(outputFormatInfoSize))
    status = AudioFormatGetProperty(kAudioFormatProperty_FormatList,
                                    UInt32(MemoryLayout<AudioFormatInfo>.size),
                                    &formatInfo,
                                    &outputFormatInfoSize,
                                    formatListItem)
//    if status != noErr {
//        return
//    }
    
    let itemCount = outputFormatInfoSize / UInt32(MemoryLayout<AudioFormatListItem>.size)
    for idx in 0..<itemCount {
        let item: AudioFormatListItem = formatListItem.advanced(by: Int(idx)).pointee
        print("channel layout tag is \(item.mChannelLayoutTag), mASBD is \(item.mASBD)")
    }
    
    closeFile(fd: fd)
}
