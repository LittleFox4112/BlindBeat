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
    
    var offset: Double = 0 // Offset for the audio playback
    private var startTime: TimeInterval? // Time when the main music started playing
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
    
    // Function to update the song position based on the elapsed time since the start time
    func updateSongPosition(currentTime: TimeInterval) {
        if let startTime = startTime {
            let elapsedTime = currentTime - startTime
            songPosition = elapsedTime
        } else {
            songPosition = 0
        }
    }
    
    // Function to play the main background music
    func playMainMusic() {
        print("main music start")
        mainAudioPlayer?.play()
        setMainMusicVolume(volume: 0.25)
        startTime = CACurrentMediaTime() // Record the start time when the music begins to play
    }
    
    // Function to stop the main background music
    func stopMainMusic() {
        print("main music stopped")
        mainAudioPlayer?.stop()
        startTime = nil // Reset the start time when the music stops
    }
    
    // Function to set the volume of the main background music
    func setMainMusicVolume(volume: Float) {
        mainAudioPlayer?.volume = volume
    }
}
