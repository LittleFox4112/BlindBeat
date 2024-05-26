//
//  MissionFailedScene.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 26/05/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

class MissionSuccessScene: SKScene, SKPhysicsContactDelegate {
    var missionSuccess: SKSpriteNode?
    var missionSuccessAudioPlayer: AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        missionSuccess = childNode(withName: "missionSuccess") as? SKSpriteNode
        missionSuccess!.isHidden = false
        let wait = SKAction.wait(forDuration: 2.0)
        let missionSuccessAudio = SKAction.run { [self] in
            playMissionFailedAudio()
        }
        self.run(SKAction.sequence([wait, missionSuccessAudio]))
    }
    
    func playMissionFailedAudio() {
        if let fileURL = Bundle.main.url(forResource: "Audio-musuh-2", withExtension: "mp3") {
            do {
                missionSuccessAudioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                missionSuccessAudioPlayer?.prepareToPlay()
                missionSuccessAudioPlayer?.volume = 1
                missionSuccessAudioPlayer?.play()
            } catch {
                print("Error playing audio file: \(error.localizedDescription)")
            }
        }
    }
}
