//
//  DodgeScene.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 15/05/24.
//

import SpriteKit
import GameplayKit
import CoreMotion

class DodgeScene: SKScene, SKPhysicsContactDelegate {
    
    // Setup gyro
    let manager = CMMotionManager()
    
    var playerSprite: PlayerSprite!
    var attackBox: AttackBox!
    var conductor = Conductor()
    
    // Attack schedule
    var attackTimes: [(time: Double, pan: Float, attackPattern: Int, delay: TimeInterval)] = [
        (4.28, -1.0, 1, 0.5),
        (6.558, 1.0, 2, 0.6),
        (8.87, -1.0, 1, 0.5),
        (12.76, 1.0, 1, 0.5),
        (15.73, -1.0, 1, 0.5),
        (17.90, -1.0, 2, 0.6),
        (20.14, 1.0, 2, 0.6),
        (21.96, -1.0, 1, 0.5),
        (23.86, -1.0, 2, 0.6)
    ]
    
    var isAttackScheduled: Bool = false
    
    private var timer: Timer?
    
    var timerLagu: SKLabelNode?
    var playerLive: SKLabelNode?
    
    override func didMove(to view: SKView) {
        // Initialize class with the scene reference
        playerSprite = PlayerSprite(scene: self)
        attackBox = AttackBox(scene: self)
        
        // Set up the scene
        self.physicsWorld.contactDelegate = self
        
        // Gyro data take
        manager.startAccelerometerUpdates()
        
        // Add and setup player node to the scene
        playerSprite.playerShow()
        
        // Start gyro updates
        startGyro()
        
        // Cek timer dan playerhealth
        timerLagu = SKLabelNode(text: "00:00")
        timerLagu?.fontSize = 60
        timerLagu?.fontColor = .black
        timerLagu?.position = CGPoint(x: 0, y: 400)
        timerLagu?.zPosition = 5
        if let timerLagu = timerLagu {
            addChild(timerLagu)
        }
        playerLive = SKLabelNode(text: "\(playerSprite.playerHealth)")
        playerLive?.position = CGPoint(x: 0, y: 500)
        playerLive?.fontSize = 60
        playerLive?.fontColor = .black
        playerLive?.zPosition = 5
        addChild(playerLive!)
        
        // Load and play your audio from conductor
        self.conductor.playMainMusic()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if playerSprite.playerSprite?.isHidden == false {
            conductor.updateSongPosition(currentTime: currentTime)
        }
        
        attackPlayer()
        if playerSprite.playerInvis > 0 {
            playerSprite.playerInvisibility()
        }
        
        let formattedSongPosition = String(format: "%.3f", conductor.songPosition)
        timerLagu?.text = formattedSongPosition
        playerLive?.text = "\(playerSprite.playerHealth)"
    }
    
    //mappingbeat di xcode
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Print the current song position when the screen is tapped
        let formattedSongPosition = String(format: "%.3f", conductor.songPosition)
        print("Current Song Position: \(formattedSongPosition) seconds")
    }
    
    // Contact delegate method --> cek collision dan kirim info
    func didBegin(_ contact: SKPhysicsContact) {
        if attackBox.attackBox?.isHidden == false && playerSprite.playerHealth > 0 {
            let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if contactMask == (CollisionCategory.player.rawValue | CollisionCategory.attack.rawValue) {
                playerSprite.playerCollision()
            }
        }
    }
    
    func startGyro() {
        if manager.isAccelerometerAvailable {
            self.manager.accelerometerUpdateInterval = 1.0/50
            self.manager.startAccelerometerUpdates()
            
            // Configure a timer to fetch the accelerometer data.
            self.timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true) { [weak self] timer in
                // Get the gyro data.
                if let data = self?.manager.accelerometerData {
                    let x = data.acceleration.y
                    
                    // Use the gyroscope data in your app.
                    self!.playerSprite.updatePlayerPosition(accelerationX: CGFloat(-x))
                }
            }
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    func stopGyro() {
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // Stop accelerometer updates
        manager.stopAccelerometerUpdates()
    }
    
    func attackPlayer() {
        if playerSprite.playerHealth > 0 {
            if let attack = attackTimes.first {
                if conductor.songPosition+0.6 >= attack.time {
                    print (conductor.songPosition)
                    print (attack.time)
                    attackBox.attackShow(pan: attack.pan, attackPattern: attack.attackPattern, delay: attack.delay)
                    // Remove this task from the list after execution
                    attackTimes.removeFirst()
                }
            }
        } else if playerSprite.playerHealth == 0 {
            playerSprite.playerHealth = -1
            conductor.stopMainMusic()
        }
    }
    
    override func willMove(from view: SKView) {
        // Ensure to stop gyro updates when the scene is removed from the view
        stopGyro()
    }
}
