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
    
    // Player
    var playerSprite: SKSpriteNode?
    var attackBox: AttackBox!
    var playerHealth: Int = 3
    var playerInvis: Int = 0
    
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
    
    // Main background song
    var conductor = Conductor()
    
    private var timer: Timer?
    
    var currentPlayerPosition: CGPoint? = CGPoint(x: 0, y: -480)
    var timerLagu: SKLabelNode?
    var playerLive: SKLabelNode?
    
    override func didMove(to view: SKView) {
        // Gyro data take
        manager.startAccelerometerUpdates()
        
        // Mendapatkan referensi ke node
        playerSprite = childNode(withName: "//playerTes") as? SKSpriteNode
        timerLagu = SKLabelNode(text: "00:00")
        timerLagu?.fontSize = 60
        timerLagu?.fontColor = .black
        timerLagu?.position = CGPoint(x: 0, y: 400)
        timerLagu?.zPosition = 5
        if let timerLagu = timerLagu {
            addChild(timerLagu)
        }
        playerLive = SKLabelNode(text: "\(playerHealth)")
        playerLive?.position = CGPoint(x: 0, y: 500)
        playerLive?.fontSize = 60
        playerLive?.fontColor = .black
        playerLive?.zPosition = 5
        addChild(playerLive!)
        
        // Add and setup player node to the scene
        playerSprite?.isHidden = false
        
        // Initialize attackBox with the scene reference
        attackBox = AttackBox(scene: self, conductor: conductor)
        
        // Start gyro updates
        startGyro()
        
        // Load and play your audio from conductor
        self.conductor.playMainMusic()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if playerSprite?.isHidden == false {
            conductor.updateSongPosition(currentTime: currentTime)
        }
        
        attackPlayer()
        playerInvisibility()
        
//        print ("\(playerHealth)")
        // Use conductor.songPosition as needed in your game logic
        // For example, print the song position
        let formattedSongPosition = String(format: "%.3f", conductor.songPosition)
        timerLagu?.text = formattedSongPosition
        playerLive?.text = "\(playerHealth)"
    }
    
    //mappingbeat di xcode
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            // Print the current song position when the screen is tapped
            let formattedSongPosition = String(format: "%.3f", conductor.songPosition)
            print("Current Song Position: \(formattedSongPosition) seconds")
        }
    
    func playerCollision() {
        if attackBox.attackBox?.isHidden == false {
            if currentPlayerPosition!.x < 0 && attackBox.panValue == -1 || currentPlayerPosition!.x > 0 && attackBox.panValue == 1 {
                print ("collision detected")
                playerHealth -= 1
                playerInvis = 60
            }
            if playerHealth == 0 {
                conductor.stopMainMusic()
                attackBox.attackStop()
            }
        }
    }
    
    func playerInvisibility() {
        if playerInvis == 0 {
            playerCollision()
        } else if playerInvis > 0 {
            playerInvis -= 1
            print("\(playerInvis)")
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
                    self?.updatePlayerPosition(accelerationX: CGFloat(-x))
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
        if playerHealth > 0 {
            if let attack = attackTimes.first {
                if conductor.songPosition+0.6 >= attack.time {
                    print (conductor.songPosition)
                    print (attack.time)
                    attackBox.attackShow(pan: attack.pan, attackPattern: attack.attackPattern, delay: attack.delay)
                    // Remove this task from the list after execution
                    attackTimes.removeFirst()
                }
            }
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
    
    override func willMove(from view: SKView) {
        // Ensure to stop gyro updates when the scene is removed from the view
        stopGyro()
    }
}
