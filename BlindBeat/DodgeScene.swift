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
        (17.90, 0, 3, 0.5),
        (20.14, 1.0, 2, 0.6),
        (21.96, -1.0, 1, 0.5),
        (23.86, 0, 4, 0.5),
        (25.89, 1.0, 1, 0.5),
        (29.75, -1.0, 2, 0.6),
        (31.99, 1.0, 1, 0.5),
        (33.91, -1.0, 2, 0.6),
        (35.97, 1.0, 2, 0.6),
        (38.74, 0, 4, 0.5),
        (40.82, 0, 3, 0.5)
    ]
    
    var isAttackScheduled: Bool = false
    // Calibration data
    var initialX: Double = 0.0
    var initialY: Double = 0.0
    var isCalibrated: Bool = false
    
    private var timer: Timer?
    
    var timerLagu: SKLabelNode?
    var playerLive: SKLabelNode?
    
    override func didMove(to view: SKView) {
        view.showsPhysics = true
        
        // Initialize class with the scene reference
        playerSprite = PlayerSprite(scene: self)
        attackBox = AttackBox(scene: self)
        
        // Set up the scene
        self.physicsWorld.contactDelegate = self
        
        // Add and setup player node to the scene
        playerSprite.playerShow()
        
        // Gyro data take
        manager.startAccelerometerUpdates()
        
        // Start gyro updates
        startGyro()
        
        // Check timer and player health
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
    
    func attackPlayer() {
        if playerSprite.playerHealth > 0 {
            if let attack = attackTimes.first {
                if conductor.songPosition + 0.6 >= attack.time {
                    print(conductor.songPosition)
                    print(attack.time)
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
    
    // Mapping beat in Xcode
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Print the current song position when the screen is tapped
        let formattedSongPosition = String(format: "%.3f", conductor.songPosition)
        print("Current Song Position: \(formattedSongPosition) seconds")
    }
    
    // Contact delegate method --> check collision and send info
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (CollisionCategory.player.rawValue | CollisionCategory.attack.rawValue) {
            if playerSprite.playerHealth > 0 && playerSprite.playerInvis == 0 {
                playerSprite.playerCollision()
            }
        }
    }
    
    func startGyro() {
        if manager.isAccelerometerAvailable {
            self.manager.accelerometerUpdateInterval = 1.0 / 50
            self.manager.startAccelerometerUpdates()
            
            // Configure a timer to fetch the accelerometer data.
            self.timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true) { [weak self] timer in
                // Get the gyro data.
                if let data = self?.manager.accelerometerData {
                    let x = data.acceleration.y
                    let y = data.acceleration.x
                    
                    // Calibration step
                    if !(self?.isCalibrated ?? true) {
                        self?.initialX = x
                        self?.initialY = y
                        self?.isCalibrated = true
                    }
                    
                    // Adjust based on calibration
                    let adjustedX = x - (self?.initialX ?? 0.0)
                    let adjustedY = y - (self?.initialY ?? 0.0)
                    
                    // Use the adjusted gyro data in your app.
                    self?.playerSprite.updatePlayerPosition(accelerationX: CGFloat(-adjustedX), accelerationY: CGFloat(adjustedY))
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
    
    
    override func willMove(from view: SKView) {
        // Ensure to stop gyro updates when the scene is removed from the view
        stopGyro()
    }
}
