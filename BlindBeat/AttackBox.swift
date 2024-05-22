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
    var warningAudioPlayer: AVAudioPlayer?
    
    // Property to store pan and pattern value
    public var panValue: Float = 0.0
    public var attackPattern: Int = 0
    
    // Attack sound player
    let attacksound1 = Bundle.main.url(forResource: "Beam-Attack-1", withExtension: "mp3")
    let attacksound2 = Bundle.main.url(forResource: "Beam-Attack-2", withExtension: "mp3")
    let attacksound3 = Bundle.main.url(forResource: "Beam-Attack-up", withExtension: "mp3")
    let attacksound4 = Bundle.main.url(forResource: "Beam-Attack-down", withExtension: "mp3")
    
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
        
        // Load the warning sound file
        if let warningSoundURL = Bundle.main.url(forResource: "AttackAlarm", withExtension: "wav") {
            do {
                // Initialize audio player with the sound file
                warningAudioPlayer = try AVAudioPlayer(contentsOf: warningSoundURL)
                warningAudioPlayer?.prepareToPlay()
            } catch {
                print("Error loading warning audio file:", error.localizedDescription)
            }
        }
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
        if attackBox!.isHidden == true || attackUpDown!.isHidden == true {
            attackBox?.physicsBody?.categoryBitMask = CollisionCategory.none.rawValue
            attackUpDown?.physicsBody?.categoryBitMask = CollisionCategory.none.rawValue
        } else {
            attackBox?.physicsBody?.categoryBitMask = CollisionCategory.attack.rawValue
            attackUpDown?.physicsBody?.categoryBitMask = CollisionCategory.attack.rawValue
        }
    }
    
    func loadAttackSound(attackPattern: Int) {
        let soundFileName: URL?
        switch attackPattern {
        case 1:
            soundFileName = attacksound1
        case 2:
            soundFileName = attacksound2
        case 3:
            soundFileName = attacksound3
        case 4:
            soundFileName = attacksound4
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
    
    func attackWarning() {
        print("Attack warning")
        // Set pan according to the stored pan value
        warningAudioPlayer?.pan = panValue
        // Play the warning sound
        warningAudioPlayer?.play()
    }
    
    func showUpDownAttack(){
        switch attackPattern {
        case 3:
            self.attackUpDown?.position.y = 417
        case 4:
            self.attackUpDown?.position.y = -417
        default:
            self.attackUpDown?.position.y = 417
        }
    }
    
    func attackShow(pan: Float, attackPattern: Int, delay: TimeInterval) {
        // Store the pan value and attack pattern
        panValue = pan
        self.attackPattern = attackPattern
        
        // Load the appropriate attack sound
        loadAttackSound(attackPattern: attackPattern)
        
        // Play the attack sound immediately
        self.attackAudioPlayer?.pan = pan
        self.attackAudioPlayer?.play()
        
        // Schedule the attackBox to be shown after the specified delay
        let showAttackBoxTask = DispatchWorkItem {
            self.adjustAttackCategoryBitMask()

            if pan == -1 {
                self.attackBox?.position.x = -609.5
                self.attackBox?.isHidden = false

            } else if pan == 1 {
                self.attackBox?.position.x = 609.5
                self.attackBox?.isHidden = false

            } else if pan == 0 {
                self.showUpDownAttack()
                self.attackUpDown?.isHidden = false
            }
            // Check if attackBox is shown
            if self.attackBox?.isHidden == false {
                print("attackBox shown")
            }else  if self.attackUpDown?.isHidden == false {
                print("attackUpDown shown")
            }
        }
        
        scheduledAttackTasks.append(showAttackBoxTask)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: showAttackBoxTask)
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
    
    // AVAudioPlayerDelegate method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == attackAudioPlayer {
            DispatchQueue.main.async {
                self.attackBox?.isHidden = true
                self.attackUpDown?.isHidden = true
                self.adjustAttackCategoryBitMask()
                self.panValue = 0
                self.attackPattern = 0
            }
        }
    }
}
