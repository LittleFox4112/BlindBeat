//
//  Conductor.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 16/05/24.
//

import SpriteKit
import AVFoundation

class Conductor {
    var mainAudioPlayer: AVAudioPlayer?
    
    var bpm: Double = 120 // Beats per minute
    var crotchet: Double {
        return 60 / bpm // Time duration of a beat in seconds
    }
    
    var offset: Double = 0 // Offset for the audio playback
    public var songPosition: TimeInterval = 0 // Current position of the song
    
    init() {
        // Load the main background music file
        if let mainMusicURL = Bundle.main.url(forResource: "HeatleyBros-8BitHero", withExtension: "mp3") {
            do {
                // Initialize audio player with the sound file
                mainAudioPlayer = try AVAudioPlayer(contentsOf: mainMusicURL)
                mainAudioPlayer?.prepareToPlay()
            } catch {
                print("Error loading main audio file:", error.localizedDescription)
            }
        }
    }
    
    // Function to update the song position based on time and offset
    func updateSongPosition(currentTime: TimeInterval) {
        if offset == 0 {
            offset = CACurrentMediaTime()
            let dspTime = currentTime - offset
            songPosition = dspTime * 1.0 // Assuming song.pitch is 1.0 for simplicity
        } else {
            let dspTime = currentTime - offset
            songPosition = dspTime * 1.0 // Assuming song.pitch is 1.0 for simplicity
        }
    }
    
    // Function to play the main background music
    func playMainMusic() {
        print("main music start")
        mainAudioPlayer?.play()
        setMainMusicVolume(volume: 0.4)
    }
    
    // Function to stop the main background music
    func stopMainMusic() {
        mainAudioPlayer?.stop()
    }
    
    // Function to set the volume of the main background music
    func setMainMusicVolume(volume: Float) {
        mainAudioPlayer?.volume = volume
    }
    
}
