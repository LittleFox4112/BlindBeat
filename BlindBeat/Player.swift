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
    var enemyAudioPlayer: AVAudioPlayer?
    var conductor = Conductor()
    public var speechPattern : Int = 0
    var enemyAudioPlaying: Bool = false
    
    var playerHealth: Int = 3
    var playerInvis: Int = 0
    var currentPlayerPosition: CGPoint? = CGPoint(x: 0, y: -400)
    
    let hitsound1 = Bundle.main.url(forResource: "Hit-sound", withExtension: "mp3")
    let enemysound1 = Bundle.main.url(forResource: "Audio-musuh-1", withExtension: "mp3")
    let enemysound2 = Bundle.main.url(forResource: "Audio-musuh-2", withExtension: "mp3")
    let enemysound3 = Bundle.main.url(forResource: "Audio-musuh-3", withExtension: "mp3")
    
    init(scene: SKScene) {
        super.init()
        // Get reference to the attack box node
        playerSprite = scene.childNode(withName: "playerTes") as? SKSpriteNode
        
        // Configure physics body for player sprite
        if let playerSprite = playerSprite {
            playerSprite.physicsBody = SKPhysicsBody(circleOfRadius: 35)
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
    
    func loadEnemySound(speechPattern: Int){
        let soundFileName: URL?
        switch speechPattern {
        case 1:
            soundFileName = enemysound1
        case 2:
            soundFileName = enemysound2
        case 3:
            soundFileName = enemysound3
        default:
            soundFileName = enemysound1 // Default sound
        }
        if let enemySoundURL = soundFileName {
            do {
                // Initialize audio player with the sound file
                enemyAudioPlayer = try AVAudioPlayer(contentsOf: enemySoundURL)
                enemyAudioPlayer?.prepareToPlay()
            } catch {
                print("Error loading attack audio file:", error.localizedDescription)
            }
        }
    }
    
    func playEnemyAudio(speechPattern: Int){
        self.speechPattern = speechPattern
        loadEnemySound(speechPattern: speechPattern)
        enemyAudioPlaying = true
        if enemyAudioPlaying == true {
            conductor.setMainMusicVolume(volume: 0.1)
            enemyAudioPlaying = false
            // delegate untuk set main music volume ke 0.3 stelah audio kelar
        } else {
            conductor.setMainMusicVolume(volume: 0.3)
        }
        self.enemyAudioPlayer?.play()
    }
    
    func playHitAudio(){
        hitAudioPlayer?.play()
        conductor.setMainMusicVolume(volume: 0.1)
        if playerInvis == 0 {
            conductor.setMainMusicVolume(volume: 0.2)
        }
    }
    
    func playerShow() {
        playerSprite?.isHidden = false
        playerInvis = 0
        playerHealth = 5
        loadHitSound()
    }
    
    func playerCollision() {
        playerHealth -= 1
        playHitAudio()
        if playerHealth > 0 {
            print("collision func detected")
            playerInvis = 100
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
        let xsensitivity: CGFloat = 350.0
        let ysensitivity: CGFloat = 250.0
        
        // Calculate new position
        let newPositionX = playerSprite!.position.x + accelerationX * xsensitivity
        let newPositionY = playerSprite!.position.y + accelerationY * ysensitivity
        
        // Ensure player stays within screen bounds
        let clampedPositionX = clamp(value: newPositionX, lower: -640, upper: 640)
        let clampedPositionY = clamp(value: newPositionY, lower: -640, upper: 640)
        
        // Update player position
        playerSprite!.position = CGPoint(x: clampedPositionX, y: clampedPositionY)
        currentPlayerPosition = playerSprite!.position
    }
    
    // Limit player movement to stay within the screen bounds
    func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
    
}
