//
//  attackCode.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 15/05/24.
//

import SpriteKit
import AVFoundation

class AttackBox: NSObject, AVAudioPlayerDelegate {
    var attackUpDown: SKSpriteNode?
    var attackBox: SKSpriteNode?
    var attackAudioPlayer: AVAudioPlayer?
    
    // Property to store pan and pattern value
    public var panValue: Float = 0.0
    public var attackPattern: Int = 0
    
    // Attack sound player
    let attacksound1 = Bundle.main.url(forResource: "Beam-Attack-1", withExtension: "mp3")
    let attacksound2 = Bundle.main.url(forResource: "Beam-Attack-2", withExtension: "mp3")
    let attacksound3 = Bundle.main.url(forResource: "Beam-Attack-Bawah", withExtension: "mp3")
    let attacksound4 = Bundle.main.url(forResource: "Beam-Attack-Atas", withExtension: "mp3")
    
    // Collection to store scheduled attack tasks
    private var scheduledAttackTasks: [DispatchWorkItem] = []
    
    init(scene: SKScene) {
        super.init()
        // Get reference to the attack box node
        attackUpDown = scene.childNode(withName: "attackUpDown") as? SKSpriteNode
        attackBox = scene.childNode(withName: "attackTes") as? SKSpriteNode
        // Configure physics body for attack box
        applyAttackPhysicsBody()
        
        attackBox?.isHidden = true
        attackUpDown?.isHidden = true
        adjustAttackCategoryBitMask()
    }
    
    func applyAttackPhysicsBody() {
        if let attackBox = attackBox, let texture = attackBox.texture {
            attackBox.physicsBody = SKPhysicsBody(texture: texture, size: attackBox.size)
            attackBox.physicsBody?.isDynamic = true
            attackBox.physicsBody?.affectedByGravity = false
            attackBox.physicsBody?.allowsRotation = false
            attackBox.physicsBody?.categoryBitMask = CollisionCategory.attack.rawValue
            attackBox.physicsBody?.contactTestBitMask = CollisionCategory.player.rawValue
            attackBox.physicsBody?.collisionBitMask = CollisionCategory.none.rawValue
        }
        
        if let attackUpDown = attackUpDown, let texture = attackUpDown.texture {
            attackUpDown.physicsBody = SKPhysicsBody(texture: texture, size: attackUpDown.size)
            attackUpDown.physicsBody?.isDynamic = true
            attackUpDown.physicsBody?.affectedByGravity = false
            attackUpDown.physicsBody?.allowsRotation = false
            attackUpDown.physicsBody?.categoryBitMask = CollisionCategory.attack.rawValue
            attackUpDown.physicsBody?.contactTestBitMask = CollisionCategory.player.rawValue
            attackUpDown.physicsBody?.collisionBitMask = CollisionCategory.none.rawValue
        }
    }
    
    func adjustAttackCategoryBitMask() {
        attackBox?.physicsBody?.categoryBitMask = attackBox!.isHidden ? CollisionCategory.none.rawValue : CollisionCategory.attack.rawValue
        attackUpDown?.physicsBody?.categoryBitMask = attackUpDown!.isHidden ? CollisionCategory.none.rawValue : CollisionCategory.attack.rawValue
    }

    
    func loadAttackSound(attackPattern: Int) {
        let soundFileName: URL?
        switch attackPattern {
        case 1:
            soundFileName = attacksound1
            attackAudioPlayer?.volume = 1.6
        case 2:
            soundFileName = attacksound2
            attackAudioPlayer?.volume = 1.6
        case 3:
            soundFileName = attacksound3
            attackAudioPlayer?.volume = 1
        case 4:
            soundFileName = attacksound4
            attackAudioPlayer?.volume = 1
        default:
            soundFileName = attacksound1 // Default sound
        }
        
        if let attackSoundURL = soundFileName {
            do {
                // Initialize audio player with the sound file
                attackAudioPlayer = try AVAudioPlayer(contentsOf: attackSoundURL)
                attackAudioPlayer?.prepareToPlay()
                attackAudioPlayer?.delegate = self // Set delegate
            } catch {
                print("Error loading attack audio file:", error.localizedDescription)
            }
        }
    }
    
    func showUpDownAttack(){
        switch attackPattern {
        case 3:
            self.attackUpDown?.position.y = 323.217
        case 4:
            self.attackUpDown?.position.y = -323.217
        default:
            self.attackUpDown?.position.y = 323.217
        }
    }
    
    func attackShow(pan: Float, attackPattern: Int) {
        // Store the pan value and attack pattern
        panValue = pan
        self.attackPattern = attackPattern

        // Set delay according to attack pattern
        let delay: TimeInterval
        switch attackPattern {
        case 1:
            delay = 0.5
        case 2:
            delay = 0.5
        case 3, 4:
            delay = 0.5
        default:
            delay = 0.5
        }
        
        loadAttackSound(attackPattern: attackPattern)
        
        // Play the attack sound immediately
        self.attackAudioPlayer?.pan = pan
        self.attackAudioPlayer?.play()
        
        // Schedule the attackBox to be shown after the specified delay
        let showAttackBoxTask = DispatchWorkItem {
            if pan == -1 {
                self.attackBox?.position.x = -326.112
                self.attackBox?.isHidden = false
                self.attackBox!.zPosition = 3

            } else if pan == 1 {
                self.attackBox?.position.x = 326.112
                self.attackBox?.isHidden = false
                self.attackBox!.zPosition = 3

            } else if pan == 0 {
                self.showUpDownAttack()
                self.attackUpDown?.isHidden = false
                self.attackUpDown!.zPosition = 3

            }
            
            self.adjustAttackCategoryBitMask()
            
            // Schedule to hide 0.1 seconds before audio finishes
            if let attackAudioPlayer = self.attackAudioPlayer {
                let hideTime = attackAudioPlayer.duration - 0.8
                DispatchQueue.main.asyncAfter(deadline: .now() + hideTime) {
                    self.hideAttackNodes()
                }
            }
        }
        
        scheduledAttackTasks.append(showAttackBoxTask)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: showAttackBoxTask)
    }
    
    func hideAttackNodes() {
        self.attackBox?.isHidden = true
        self.attackUpDown?.isHidden = true
        self.adjustAttackCategoryBitMask()
        self.panValue = 0
        self.attackPattern = 0
    }
    
    func attackStop() {
        print("Attack stopped")
        attackBox?.isHidden = true
        adjustAttackCategoryBitMask()
        panValue = 0
        attackPattern = 0
        
        // Cancel all scheduled attack tasks
        for task in scheduledAttackTasks {
            task.cancel()
        }
        scheduledAttackTasks.removeAll()
    }
}
