//
//  attackCode.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 15/05/24.
//

import SpriteKit
import AVFoundation

class AttackBox: NSObject, AVAudioPlayerDelegate {
    var attackBox: SKSpriteNode?
    var attackAudioPlayer: AVAudioPlayer?
    var warningAudioPlayer: AVAudioPlayer?
    var conductor: Conductor
    
    // Property to store pan and pattern value
    public var panValue: Float = 0.0
    public var attackPattern: Int = 0
    
    // Collection to store scheduled attack tasks
    private var scheduledAttackTasks: [DispatchWorkItem] = []
    
    init(scene: SKScene, conductor: Conductor) {
        self.conductor = conductor
        
        super.init()
        // Get reference to the attack box node
        attackBox = scene.childNode(withName: "attackTes") as? SKSpriteNode
        attackBox?.isHidden = true
        
        // Load the warning sound file
        if let warningSoundURL = Bundle.main.url(forResource: "AttackAlarm", withExtension: "wav") {
            do {
                // Initialize audio player with the sound file
                warningAudioPlayer = try AVAudioPlayer(contentsOf: warningSoundURL)
                warningAudioPlayer?.prepareToPlay()
            } catch {
                print("Error loading warning audio file:", error.localizedDescription)
            }
        }
    }
    
    func loadAttackSound(attackPattern: Int) {
        let soundFileName: String
        switch attackPattern {
        case 1:
            soundFileName = "Beam-Attack-1"
        case 2:
            soundFileName = "Beam-Attack-2"
        default:
            soundFileName = "Beam-Attack-1" // Default sound
        }
        
        if let attackSoundURL = Bundle.main.url(forResource: soundFileName, withExtension: "mp3") {
            do {
                // Initialize audio player with the sound file
                attackAudioPlayer = try AVAudioPlayer(contentsOf: attackSoundURL)
                attackAudioPlayer?.prepareToPlay()
                attackAudioPlayer?.delegate = self // Set delegate
                print("Attack sound loaded successfully: \(soundFileName)")
            } catch {
                print("Error loading attack audio file:", error.localizedDescription)
            }
        }
    }
    
    func attackWarning() {
        print("Attack warning")
        // Set pan according to the stored pan value
        warningAudioPlayer?.pan = panValue
        // Play the warning sound
        warningAudioPlayer?.play()
    }
    
    func attackShow(pan: Float, attackPattern: Int, delay: TimeInterval) {
        // Store the pan value and attack pattern
        panValue = pan
        self.attackPattern = attackPattern
        
        // Load the appropriate attack sound
        loadAttackSound(attackPattern: attackPattern)
        
        // Play the attack sound immediately
        print("Playing attack sound immediately with pattern \(attackPattern) and pan \(pan)")
        self.attackAudioPlayer?.pan = pan
        self.attackAudioPlayer?.play()
        
        // Schedule the attackBox to be shown after the specified delay
        let showAttackBoxTask = DispatchWorkItem {
            print("Showing attackBox")
            // Set attackBox position according to pan
            if pan == -1 {
                self.attackBox?.position.x = -609.5
            } else if pan == 1 {
                self.attackBox?.position.x = 609.5
            }
            // Unhide the attackBox
            self.attackBox?.isHidden = false
        }
        
        scheduledAttackTasks.append(showAttackBoxTask)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: showAttackBoxTask)
    }
    
    func scheduleBeamAttacks() {
        
        print("beam attack scheduled")
        let attackTimes: [(time: TimeInterval, pan: Float, attackPattern: Int, delay: TimeInterval)] = [
            (3.29, -1.0, 1, 0.25),
            (6.05, 1.0, 2, 0.08),
            (8.12, -1.0, 1, 0.25),
            (12.06, 1.0, 1, 0.25),
            (15.03, -1.0, 1, 0.25),
            (17.28, 1.0, 2, 0.08),
            (20.06, -1.0, 2, 0.08),
            (21.26, 1.0, 1, 0.25),
            (23.16, -1.0, 2, 0.08)
        ]
        
        let currentSongPosition = conductor.songPosition
        
        for attack in attackTimes {
            let startSongPosition = currentSongPosition + attack.time
            let attackTimetoSongPos = startSongPosition - currentSongPosition
            
            let attackTask = DispatchWorkItem { [weak self] in
                print("Executing attack at time \(attackTimetoSongPos)")
                self?.attackShow(pan: attack.pan, attackPattern: attack.attackPattern, delay: attack.delay)
            }
            
            scheduledAttackTasks.append(attackTask)
            DispatchQueue.main.asyncAfter(deadline: .now() + attackTimetoSongPos, execute: attackTask)
        }
    }
    
    
    func attackStop() {
        print("Attack stopped")
        attackBox?.isHidden = true
        panValue = 0
        attackPattern = 0
        
        // Cancel all scheduled attack tasks
        for task in scheduledAttackTasks {
            task.cancel()
        }
        scheduledAttackTasks.removeAll()
    }
    
    // AVAudioPlayerDelegate method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == attackAudioPlayer {
            DispatchQueue.main.async {
                self.attackBox?.isHidden = true
                self.panValue = 0
                self.attackPattern = 0
            }
        }
    }
}
