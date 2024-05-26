//
//  Tutorial.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 25/05/24.
//

import SpriteKit
import AVFoundation
import CoreMotion
import AVKit

class TutorialScene: SKScene, AVAudioPlayerDelegate {
    var motionManager: CMMotionManager!
    var audioPlayer: AVAudioPlayer?
    var introBGPlayer: AVAudioPlayer?
    var timer: Timer?
    var calibrationCompleted = false
    
    var isScreenTappable = false
    
    var beginScreen: SKSpriteNode?
    
    var instruksi3Completed: Bool = false
    var currentlyStep: Int = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black

        beginScreen = childNode(withName: "beginScreen") as? SKSpriteNode
        beginScreen?.position = CGPoint(x: 0, y: 0)
        beginScreen?.isHidden = true
        
        motionManager = CMMotionManager()
        playInstructionVideo()
        
        let waitVideo = SKAction.wait(forDuration: 16.0)
        let showNextStep = SKAction.run { [self] in
            self.showStep3()
        }
        self.run(SKAction.sequence([waitVideo, showNextStep]))
    }
    
    func playInstructionVideo() {
        print("Attempting to play instruction video")
        let sample = SKVideoNode(fileNamed: "VideoInstruksi.mp4")
        sample.position = CGPoint(x: 0, y: 0)
        addChild(sample)
        sample.play()
    }
    
    func showStep3() {
        currentlyStep = 3
        
        beginScreen?.isHidden = false
        beginScreen?.zPosition = 1
        beginScreen?.alpha = 0.0
        
        let fadeInAction = SKAction.fadeIn(withDuration: 2.0)
        beginScreen?.run(fadeInAction)
        playIntroBGMusic()
        
        let wait = SKAction.wait(forDuration: 3.0)
        let waitUntilAudio3Finishes = SKAction.wait(forDuration: 4.0)
        let playAudio3 = SKAction.run { [self] in
            playAudio(named: "Instruksi3")
        }
        let toggleInstruksi3 = SKAction.run { [self] in
            instruksi3Completed = true
        }
        self.run(SKAction.sequence([wait, playAudio3, waitUntilAudio3Finishes, toggleInstruksi3]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if instruksi3Completed {
            changeToStoryScene()
        }
    }
    
    func changeToStoryScene() {
        self.removeAllActions()
        let storyScene = StoryScene(size: self.size)
        storyScene.scaleMode = .aspectFill
        storyScene.position = CGPoint(x: 0, y: 0)
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(storyScene, transition: transition)
    }
    
    func playAudio(named fileName: String) {
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = 0.8
                audioPlayer?.play()
            } catch {
                print("Error playing audio file: \(error.localizedDescription)")
            }
        }
    }
    
    func playIntroBGMusic() {
        if let fileURL = Bundle.main.url(forResource: "waitscreen-music", withExtension: "mp3") {
            do {
                introBGPlayer = try AVAudioPlayer(contentsOf: fileURL)
                introBGPlayer?.numberOfLoops = -1 // Loop indefinitely
                introBGPlayer?.prepareToPlay()
                introBGPlayer?.volume = 0.3
                introBGPlayer?.play()
            } catch {
                print("Error playing intro background music: \(error.localizedDescription)")
            }
        }
    }
    
    override func willMove(from view: SKView) {
        introBGPlayer?.stop()
    }
}

