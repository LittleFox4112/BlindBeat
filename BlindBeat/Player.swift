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
<<<<<<< Updated upstream
    var playerSprite: SKSpriteNode?
=======
    static let shared = PlayerSprite()
    
    var playerSprite: SKSpriteNode!
>>>>>>> Stashed changes
    var hitAudioPlayer: AVAudioPlayer?
    var enemyAudioPlayer: AVAudioPlayer?
    var conductor = Conductor()
    public var speechPattern: Int = 0
    var enemyAudioPlaying: Bool = false
    
    var playerHealth: Int = 3
    var playerInvis: Int = 0
    var currentPlayerPosition: CGPoint? = CGPoint(x: 0, y: 0)
    var lastKnownPosition: CGPoint?
    
    let hitsound1 = Bundle.main.url(forResource: "Hit-sound", withExtension: "mp3")
    let enemysound1 = Bundle.main.url(forResource: "Audio-musuh-1", withExtension: "mp3")
    let enemysound2 = Bundle.main.url(forResource: "Audio-musuh-2", withExtension: "mp3")
    let enemysound3 = Bundle.main.url(forResource: "Audio-musuh-3", withExtension: "mp3")
    
    private override init() {
        super.init()
<<<<<<< Updated upstream
        // Get reference to the attack box node
=======
        // Initialization code that doesn't rely on an SKScene
        if let initialPosition = playerSprite?.position {
                currentPlayerPosition = lastKnownPosition
            } else {
                // Default position if playerSprite is nil or its position is not set
                currentPlayerPosition = CGPoint(x: 0, y: 0)
            }
    }
    
    func initialize(with scene: SKScene) {
>>>>>>> Stashed changes
        playerSprite = scene.childNode(withName: "playerTes") as? SKSpriteNode
        playerSprite?.position = currentPlayerPosition!
        
        if let playerSprite = playerSprite {
            playerSprite.physicsBody = SKPhysicsBody(circleOfRadius: 35)
            playerSprite.physicsBody?.isDynamic = true
            playerSprite.physicsBody?.affectedByGravity = false
            playerSprite.physicsBody?.allowsRotation = false
            playerSprite.physicsBody?.categoryBitMask = CollisionCategory.player.rawValue
            playerSprite.physicsBody?.contactTestBitMask = CollisionCategory.attack.rawValue
            playerSprite.physicsBody?.collisionBitMask = CollisionCategory.none.rawValue
        }
    }
    
    func loadHitSound() {
        if let hitSoundURL = hitsound1 {
            do {
                hitAudioPlayer = try AVAudioPlayer(contentsOf: hitSoundURL)
                hitAudioPlayer?.prepareToPlay()
            } catch {
                print("Error loading attack audio file:", error.localizedDescription)
            }
        }
    }
    
    func loadEnemySound(speechPattern: Int) {
        let soundFileName: URL?
        switch speechPattern {
        case 1:
            soundFileName = enemysound1
        case 2:
            soundFileName = enemysound2
        case 3:
            soundFileName = enemysound3
        default:
            soundFileName = enemysound1
        }
        if let enemySoundURL = soundFileName {
            do {
                enemyAudioPlayer = try AVAudioPlayer(contentsOf: enemySoundURL)
                enemyAudioPlayer?.prepareToPlay()
            } catch {
                print("Error loading attack audio file:", error.localizedDescription)
            }
        }
    }
    
    func playEnemyAudio(speechPattern: Int) {
        self.speechPattern = speechPattern
        loadEnemySound(speechPattern: speechPattern)
        enemyAudioPlaying = true
<<<<<<< Updated upstream
        if enemyAudioPlaying == true {
            conductor.setMainMusicVolume(volume: 0.1)
            enemyAudioPlaying = false
            // delegate untuk set main music volume ke 0.3 stelah audio kelar
=======
        if enemyAudioPlaying {
            conductor.setMainMusicVolume(volume: 0.1)
            enemyAudioPlaying = false
>>>>>>> Stashed changes
        } else {
            conductor.setMainMusicVolume(volume: 0.3)
        }
        self.enemyAudioPlayer?.play()
    }
    
<<<<<<< Updated upstream
    func playHitAudio(){
=======
    func playHitAudio() {
>>>>>>> Stashed changes
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
        playerSprite?.zPosition = 2
        playerSprite?.position = currentPlayerPosition!
        loadHitSound()
    }
    
    func playerCollision() {
        print("collision detected")
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
        let xsensitivity: CGFloat = 350.0
        let ysensitivity: CGFloat = 250.0
        
        let newPositionX = playerSprite!.position.x + accelerationX * xsensitivity
        let newPositionY = playerSprite!.position.y + accelerationY * ysensitivity
        
        let clampedPositionX = clamp(value: newPositionX, lower: -640, upper: 640)
        let clampedPositionY = clamp(value: newPositionY, lower: -640, upper: 640)
        
        playerSprite!.position = CGPoint(x: clampedPositionX, y: clampedPositionY)
        currentPlayerPosition = playerSprite!.position
        lastKnownPosition = playerSprite!.position
        
        print (currentPlayerPosition)
        print (lastKnownPosition)
    }
<<<<<<< Updated upstream
    
    // Limit player movement to stay within the screen bounds
=======

>>>>>>> Stashed changes
    func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
}
