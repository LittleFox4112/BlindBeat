//
//  Player.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 21/05/24.
//

import SpriteKit
import GameplayKit
import CoreMotion

class playerSprite: NSObject {
    var playerSprite: SKSpriteNode?
    var playerHealth: Int = 3
    var playerInvis: Int = 0
    
    init(scene: SKScene, conductor: Conductor) {
        
        super.init()
        // Get reference to the attack box node
        playerSprite = scene.childNode(withName: "playerTes") as? SKSpriteNode
        playerSprite?.isHidden = false
        
    }
}
