//
//  StoryScene.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 26/05/24.
//

import SpriteKit
import AVFoundation
import AVKit

class StoryScene: SKScene, AVAudioPlayerDelegate {
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
        
        playStoryVideo()
        
        let waitVideo = SKAction.wait(forDuration: 107.0)
        let showDodgeScene = SKAction.run { [self] in
            self.changeToDodgeScene()
        }
        self.run(SKAction.sequence([waitVideo, showDodgeScene]))
    }
    
    func playStoryVideo() {
        print("Attempting to play story video")
        let sample = SKVideoNode(fileNamed: "storySceneVideo.mp4")
        sample.position = CGPoint(x: 0, y: 0)
        addChild(sample)
        sample.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        changeToDodgeScene()
    }
    
    func changeToDodgeScene() {
        self.removeAllActions()
        let transition = SKTransition.fade(withDuration: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let dodgeScene = DodgeScene(fileNamed: "DodgeScene") {
                dodgeScene.scaleMode = .aspectFill
                dodgeScene.position = CGPoint(x: 0, y: 0)
                self.view?.presentScene(dodgeScene, transition: transition)
            }
        }
    }
    

    override func willMove(from view: SKView) {
        self.removeAllActions()
    }
}

