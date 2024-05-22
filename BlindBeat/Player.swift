//
//  Player.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 21/05/24.
//

import SpriteKit
import GameplayKit
import AVFoundation

class PlayerSprite: NSObject {
    var playerSprite: SKSpriteNode?
    var hitAudioPlayer: AVAudioPlayer?
    var conductor = Conductor()
    
    var playerHealth: Int = 3
    var playerInvis: Int = 0
    var currentPlayerPosition: CGPoint? = CGPoint(x: 0, y: -400)
    
    let hitsound1 = Bundle.main.url(forResource: "Hit-sound", withExtension: "mp3")
    
    init(scene: SKScene) {
        super.init()
        // Get reference to the attack box node
        playerSprite = scene.childNode(withName: "playerTes") as? SKSpriteNode
        
        // Configure physics body for player sprite
        if let playerSprite = playerSprite, let texture = playerSprite.texture {
            playerSprite.physicsBody = SKPhysicsBody(texture: texture, size: playerSprite.size)
            playerSprite.physicsBody?.isDynamic = true
            playerSprite.physicsBody?.affectedByGravity = false
            playerSprite.physicsBody?.allowsRotation = false
            playerSprite.physicsBody?.categoryBitMask = CollisionCategory.player.rawValue //dia kategori apa
            playerSprite.physicsBody?.contactTestBitMask = CollisionCategory.attack.rawValue //deteksi contact dengan apa
            playerSprite.physicsBody?.collisionBitMask = CollisionCategory.none.rawValue //efek kontak dengan apa
        }
    }
    
    func loadHitSound() {
        if let hitSoundURL = hitsound1 {
            do {
                // Initialize audio player with the sound file
                hitAudioPlayer = try AVAudioPlayer(contentsOf: hitSoundURL)
                hitAudioPlayer?.prepareToPlay()
            } catch {
                print("Error loading attack audio file:", error.localizedDescription)
            }
        }
    }
    
    func playHitAudio(){
        hitAudioPlayer?.play()
        conductor.setMainMusicVolume(volume: 0.1)
        if playerInvis == 0 {
            conductor.setMainMusicVolume(volume: 0.3)
        }
    }
    
    func playerShow() {
        playerSprite?.isHidden = false
        playerInvis = 0
        playerHealth = 3
        loadHitSound()
    }
    
    func playerCollision() {
        playerHealth -= 1
        playHitAudio()
        if playerHealth > 0 {
            print("collision func detected")
            playerInvis = 60
            print (playerHealth)
        }
    }
    
    func playerInvisibility() {
        if playerInvis > 0 {
            playerInvis -= 1
            print("\(playerInvis)")
        }
    }
    
    func updatePlayerPosition(accelerationX: CGFloat, accelerationY: CGFloat) {
        // Adjust sensitivity
        let sensitivity: CGFloat = 250.0
        
        // Calculate new position
        let newPositionX = playerSprite!.position.x + accelerationX * sensitivity
        let newPositionY = playerSprite!.position.y + accelerationY * sensitivity
        
        // Ensure player stays within screen bounds
        let clampedPositionX = clamp(value: newPositionX, lower: -900, upper: 900)
        let clampedPositionY = clamp(value: newPositionY, lower: -640, upper: 640)
        
        // Update player position
        playerSprite!.position = CGPoint(x: clampedPositionX, y: clampedPositionY)
        currentPlayerPosition = playerSprite!.position
    }
    
    func hitPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == hitAudioPlayer {
            DispatchQueue.main.async {
                
            }
        }
    }
    
    // Limit player movement to stay within the screen bounds
    func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
    
}
