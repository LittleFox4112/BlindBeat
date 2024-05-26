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
    
    var isScreenTappable: Bool = false
    
    override func didMove(to view: SKView) {
        missionFailed = childNode(withName: "missionFailed") as? SKSpriteNode
        missionFailed?.isHidden = false
        let wait = SKAction.wait(forDuration: 2.0)
        let missionFailedAudio = SKAction.run { [self] in
            playMissionFailedAudio()
            isScreenTappable = true
        }
        self.run(SKAction.sequence([wait, missionFailedAudio]))
    }
    
    func playMissionFailedAudio() {
        if let fileURL = Bundle.main.url(forResource: "Audio-musuh-1", withExtension: "mp3") {
            do {
                missionFailedAudioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                missionFailedAudioPlayer?.prepareToPlay()
                missionFailedAudioPlayer?.volume = 1
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
