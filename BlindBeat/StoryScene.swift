//
//  StoryScene.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 26/05/24.
//

import SpriteKit
import AVFoundation
import AVKit

class StoryScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
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
        let storyVid = SKVideoNode(fileNamed: "storySceneVideo.mp4")
        storyVid.position = CGPointZero
        storyVid.size = self.size
        storyVid.zPosition = 1
        addChild(storyVid)
        storyVid.play()
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

