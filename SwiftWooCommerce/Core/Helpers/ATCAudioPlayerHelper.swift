//
//  ATCAudioPlayerHelper.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class ATCAudioPlayerHelper: NSObject, ObservableObject, AVAudioPlayerDelegate {
    let objectWillChange = PassthroughSubject<ATCAudioPlayerHelper, Never>()
    var isPlaying = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    var audioPlayer: AVAudioPlayer!
    func startPlayback(audio: URL, isPause: Bool = false) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            audioPlayer.delegate = self
            if isPause {
                audioPlayer.pause()
            } else {
                audioPlayer.play()
            }
            isPlaying = true
        } catch {
            print("Playback Failed")
            print(error)
        }
    }
    
    func stopPlayback() {
        audioPlayer.stop()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
}
