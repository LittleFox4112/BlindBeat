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
    var isScreenTappable: Bool = false
    
    override func didMove(to view: SKView) {
        missionSuccess = childNode(withName: "missionSuccess") as? SKSpriteNode
        missionSuccess!.isHidden = true
        missionSuccess?.zPosition = 1
        missionSuccess?.position = CGPointZero
        missionSuccess?.isHidden = false
        isScreenTappable = true

        let wait = SKAction.wait(forDuration: 1.0)
        let missionSuccessAudio = SKAction.run { [self] in
            playMissionFailedAudio()
            isScreenTappable = true
        }
        self.run(SKAction.sequence([wait, missionSuccessAudio]))
    }
    
    func playMissionFailedAudio() {
        //ganti audio jadi mission success scene
        if let fileURL = Bundle.main.url(forResource: "missionSuccessAudio", withExtension: "mp3") {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeAllActions()
        let transition = SKTransition.fade(withDuration: 1.0)
        
        if isScreenTappable {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if let finishedScene = FinishedScene(fileNamed: "FinishedScene") {
                    finishedScene.scaleMode = .aspectFill
                    finishedScene.position = CGPoint(x: 0, y: 0)
                    self.view?.presentScene(finishedScene, transition: transition)
                }
            }
        }
    }
}
