//: Playground - noun: a place where people can play

import UIKit
import AudioToolbox

func openFile() -> AudioFileID? {
    let url = Bundle.main.url(forResource: "guitar", withExtension: "m4a")
    var fd: AudioFileID? = nil
    AudioFileOpenURL(url! as CFURL, .readPermission, kAudioFileM4AType, &fd)
    
    return fd
}

func closeFile(fd: AudioFileID) {
    AudioFileClose(fd)
}

let fd = openFile()
if let fd = fd {
    Swift.print("open file succeed")
    closeFile(fd: fd)
}
