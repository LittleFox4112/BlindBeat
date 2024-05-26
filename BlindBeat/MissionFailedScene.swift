//
//  MissionFailedScene.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 26/05/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

class MissionFailedScene: SKScene, SKPhysicsContactDelegate {
    var missionFailed: SKSpriteNode?
    var missionFailedAudioPlayer: AVAudioPlayer?
    
    var conductor = Conductor()
    var timeLived: SKLabelNode?
    var isScreenTappable: Bool = false
    
    var songPosition: Double = 0.0 // Add this property
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        missionFailed = childNode(withName: "failed") as? SKSpriteNode
        missionFailed?.isHidden = true
        missionFailed?.zPosition = 1
        missionFailed?.position = CGPointZero
        missionFailed?.isHidden = false
        
        // Initialize the timeLived label
        timeLived = SKLabelNode(fontNamed: "Inter")
        timeLived?.fontSize = 40
        timeLived?.fontColor = SKColor.white
        timeLived?.position = CGPoint(x: 0, y: 400)
        timeLived?.zPosition = 5
        
        if let timeLived = timeLived {
            addChild(timeLived)
        }
        
        // Set the initial text for timeLived label with the passed songPosition
        let formattedSongPosition = String(format: "%.2f", songPosition)
        timeLived?.text = "You Survived : \(formattedSongPosition) seconds"
        
        isScreenTappable = true
        
        let wait = SKAction.wait(forDuration: 1.0)
        let missionFailedAudio = SKAction.run { [self] in
            playMissionFailedAudio()
        }
        self.run(SKAction.sequence([wait, missionFailedAudio]))
    }
    
    func playMissionFailedAudio() {
        //ganti audio jadi mission fail scene
        if let fileURL = Bundle.main.url(forResource: "missionFailedAudio", withExtension: "mp3") {
            do {
                missionFailedAudioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                missionFailedAudioPlayer?.prepareToPlay()
                missionFailedAudioPlayer?.volume = 1.3
                missionFailedAudioPlayer?.play()
            } catch {
                print("Error playing audio file: \(error.localizedDescription)")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeAllActions()
        let transition = SKTransition.fade(withDuration: 1.0)
        
        if isScreenTappable {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if let dodgeScene = DodgeScene(fileNamed: "DodgeScene") {
                    dodgeScene.scaleMode = .aspectFill
                    dodgeScene.position = CGPoint(x: 0, y: 0)
                    self.view?.presentScene(dodgeScene, transition: transition)
                }
            }
        }
    }
}
