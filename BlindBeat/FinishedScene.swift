//
//  MissionFailedScene.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 26/05/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

class FinishedScene: SKScene, SKPhysicsContactDelegate {
    var finishedScene: SKSpriteNode?
    var finishAudioPlayer: AVAudioPlayer?
    var isScreenTappable: Bool = false
    var introBGPlayer: AVAudioPlayer?

    override func didMove(to view: SKView) {
        finishedScene = childNode(withName: "finish") as? SKSpriteNode
        finishedScene!.isHidden = true
        finishedScene?.zPosition = 1
        finishedScene?.position = CGPointZero
        finishedScene?.isHidden = false
        
        playIntroBGMusic()
        let wait = SKAction.wait(forDuration: 2.0)
        let finishAudio = SKAction.run { [self] in
            playFinishAudio()
            isScreenTappable = true
        }
        self.run(SKAction.sequence([wait, finishAudio]))
    }
    
    func playFinishAudio() {
        //ganti audio jadi finished scene
        if let fileURL = Bundle.main.url(forResource: "missionFinishedAudio", withExtension: "mp3") {
            do {
                finishAudioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                finishAudioPlayer?.prepareToPlay()
                finishAudioPlayer?.volume = 1
                finishAudioPlayer?.play()
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
