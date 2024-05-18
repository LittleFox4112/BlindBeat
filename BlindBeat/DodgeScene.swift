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
    
    //main bg song
    var conductor = Conductor()
    
    private var timer: Timer?
    
    var currentPlayerPosition: CGPoint? = CGPoint(x: 0, y: -480)
    
    override func didMove(to view: SKView) {
        // Gyro data take
        manager.startAccelerometerUpdates()
        
        // Mendapatkan referensi ke node
        playerSprite = childNode(withName: "//playerTes") as? SKSpriteNode

        // Add and setup player node to the scene
        playerSprite?.isHidden = false
        
        // Initialize attackBox with the scene reference
        attackBox = AttackBox(scene: self, conductor: conductor)
        
        // Start gyro updates
        startGyro()
        
        // Load and play your audio from conductor
        conductor.playMainMusic()
        
        DispatchQueue.main.async {
            // Record the current time as the starting time
            self.conductor.offset = CACurrentMediaTime()
            //start attack
            self.attackBox.scheduleBeamAttacks()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update the song position on every frame
        conductor.updateSongPosition(currentTime: currentTime)
        
        if playerInvis == 0 {
            playerCollision()
        } else if playerInvis > 0 {
            playerInvis -= 1
            print("\(playerInvis)")
        }
        
        print ("\(playerHealth)")
        // Use conductor.songPosition as needed in your game logic
        // For example, print the song position
        let formattedSongPosition = String(format: "%.4f", conductor.songPosition)
        print("Song Position: \(formattedSongPosition) seconds")
    }
    
    func playerCollision() {
        if attackBox.attackBox?.isHidden == false {
            if currentPlayerPosition!.x < 0 && attackBox.panValue == -1 || currentPlayerPosition!.x > 0 && attackBox.panValue == 1{
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
    
    func updatePlayerPosition(accelerationX: CGFloat) {
        // Adjust sensitivity
        let sensitivity: CGFloat = 500.0
        
        // Calculate new position
        let newPositionX = playerSprite!.position.x + accelerationX * sensitivity
        
        // Ensure player stays within screen bounds
        let clampedPositionX = clamp(value: newPositionX, lower: -900, upper: 900)
        
        // Update player position
        playerSprite!.position = CGPoint(x: clampedPositionX, y: playerSprite!.position.y)
        currentPlayerPosition = playerSprite!.position
    }
    
    //limitasi gerakan player agar tidak keluar dari screen
    func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
    
    override func willMove(from view: SKView) {
        // Ensure to stop gyro updates when the scene is removed from the view
        stopGyro()
    }
}
