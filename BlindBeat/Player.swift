//
//  Player.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 21/05/24.
//

import SpriteKit
import GameplayKit
import CoreMotion

class PlayerSprite: NSObject {
    var playerSprite: SKSpriteNode?
    var playerHealth: Int = 3
    var playerInvis: Int = 0
    var currentPlayerPosition: CGPoint? = CGPoint(x: 0, y: -480)
        
    init(scene: SKScene) {
        super.init()
        // Get reference to the attack box node
        playerSprite = scene.childNode(withName: "playerTes") as? SKSpriteNode
        // Configure physics body for player sprite
        playerSprite!.physicsBody = SKPhysicsBody(rectangleOf: playerSprite!.size)
        playerSprite!.physicsBody?.isDynamic = true
        playerSprite!.physicsBody?.affectedByGravity = false
        playerSprite!.physicsBody?.allowsRotation = false
        playerSprite!.physicsBody?.categoryBitMask = CollisionCategory.player.rawValue //class masuk ke kategori apa
        playerSprite!.physicsBody?.contactTestBitMask = CollisionCategory.attack.rawValue //detect contact dengan siapa
        playerSprite!.physicsBody?.collisionBitMask = CollisionCategory.none.rawValue //respond collision ke siapa
    }
    
    func playerShow() {
        playerSprite?.isHidden = false
    }
    
    func playerCollision() {
        playerHealth -= 1
        if playerHealth > 0 {
                print("collision func detected")
                playerInvis = 60
                print (playerHealth)
        }
        }
    
    func playerInvisibility() {
        if playerInvis > 0 {
            playerInvis -= 1
//            print("\(playerInvis)")
        }
    }
    
    func updatePlayerPosition(accelerationX: CGFloat) {
        // Adjust sensitivity
        let sensitivity: CGFloat = 300.0
        
        // Calculate new position
        let newPositionX = playerSprite!.position.x + accelerationX * sensitivity
        
        // Ensure player stays within screen bounds
        let clampedPositionX = clamp(value: newPositionX, lower: -900, upper: 900)
        
        // Update player position
        playerSprite!.position = CGPoint(x: clampedPositionX, y: playerSprite!.position.y)
        currentPlayerPosition = playerSprite!.position
    }
    
    // Limit player movement to stay within the screen bounds
    func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
    
}
