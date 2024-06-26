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
    var containerPlayer:SKSpriteNode?
    var background = SKSpriteNode(imageNamed: "background")
    var backgroundEfekSamping = SKSpriteNode(imageNamed: "efekSamping")
    
    // Attack schedule
    var attackTimes: [(time: Double, pan: Float, attackPattern: Int)] = [
        (4.28, -1.0, 1),
        (6.558, 1.0, 2),
        (8.87, -1.0, 1),
        (17.90, 0, 3),
        (20.14, 1.0, 2),
        (21.96, -1.0, 1),
        (23.86, 0, 4),
        (25.89, 1.0, 1),
        (29.75, -1.0, 2),
        (31.99, 1.0, 1),
        (33.91, -1.0, 2),
        (35.97, 1.0, 2),
        (38.74, 0, 4),
        (40.80, 0, 3),
        (44.95, 1.0, 2),
        (47.70,-1.0, 2),
        (48.71, 0, 4),
        (50.81, -1.0, 2),
        (51.86, 1.0, 1),
        (52.90, -1.0, 1),
        (53.93, 0, 3),
        (55.82, 0, 3),
        (57.72, 0, 4),
        (58.80, 1, 2),
        (60.84, -1, 2),
        (61.87, 1, 1),
        (63.81, 0, 3),
        (64.97, 1, 2),
        (67.77, -1, 2),
        (68.87, 1, 1),
        (69.84, 1, 1),
        (71.91, -1, 2),
        (72.96, 0, 4),
        (74.95, 0, 3),
        (75.82, 1, 1),
        (76.93, -1, 2),
        (78.99, 0, 3),
        (80.90, 0, 4),
        (82.97, 1, 1),
        (84.72, -1, 2),
        (85.77, -1, 2),
        (86.77, 1, 2),
        (87.82, 0, 4),
        (89.73, -1, 2),
        (91.94, -1, 1),
        (93.70, 0, 3),
        (94.78, 1, 2),
        (95.94, 0, 3),
        (98.84, 0, 4),
        (100.79, 1, 2),
        (101.91, -1, 2),
        (103.74, 0, 4),
        (105.79, -1, 2),
        (106.81, 1, 2),
        (107.75, 0, 3),
        (114.80, 0, 3),
        (116.70, 0, 4),
        (117.83, -1, 2),
        (118.94, -1, 1),
        (119.97, 1, 2),
        (121.71, 0, 3),
        (123.77, 0, 3),
        (125.89, -1, 1),
        (127.78, 1, 2),
        (128.76, -1, 2),
        (129.98, -1, 1),
        (131.74, 1, 2),
        (132.76, -1, 1),
        (133.97, -1, 1),
        (135.88, 0, 4),
        (136.92, 0, 3)
    ]
    
    var enemyAudioTimes: [(time: Double, speechPattern: Int)] = [
        (12.76, 1),
        (42.90, 2),
        (109.92, 3)
    ]
    
    var isAttackScheduled: Bool = false
    // Calibration data
    var initialX: Double = 0.0
    var initialY: Double = 0.0
    
    private var timer: Timer?
    
    var heartNodes: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
//        view.showsPhysics = true
        
        playerSprite = PlayerSprite(scene: self)
        attackBox = AttackBox(scene: self)
        containerPlayer = scene!.childNode(withName: "containerPlayer") as? SKSpriteNode
        
        // TODO: Late Initialisation, should be make as component in independent function: pisah function
        // Initialize heart nodes based on player's health
        let heartSize = CGSize(width: 165, height: 151)
        let heartGap: CGFloat = -50
        
        // TODO: Separate calculate and initialisation
        // Calculate starting x position so the hearts are centered
        let totalWidth = CGFloat(playerSprite.playerHealth) * heartSize.width + CGFloat(playerSprite.playerHealth - 1) * heartGap
        let startX = -totalWidth / 2 + heartSize.width / 2
        
        for i in 0..<playerSprite.playerHealth {
            let heart = SKSpriteNode(imageNamed: "playerHealth")
            heart.size = heartSize
            heart.position = CGPoint(x: startX + CGFloat(i) * (heartSize.width + heartGap), y: 643.36)
            heart.zPosition = 5
            heartNodes.append(heart)
            addChild(heart)
        }
        
        background.zPosition = 0
        background.position = CGPoint(x: 0, y: 0)
        background.size = CGSize (width: 2400, height: 1680)
        backgroundEfekSamping.zPosition = 1
        backgroundEfekSamping.position = CGPoint(x: 0, y: 0)
        backgroundEfekSamping.size = CGSize (width: 2400, height: 1680)
        
        addChild(background)
        addChild(backgroundEfekSamping)
        background.isHidden = false
        backgroundEfekSamping.isHidden = false
        
        self.physicsWorld.contactDelegate = self
        
        playerSprite.playerShow()
        if let playerSprite = playerSprite {
            print("playerSprite in DodgeScene: \(playerSprite)")
            playerSprite.playerSprite?.position = CGPoint(x: 0, y: 0)
        } else {
            print("playerSprite is nil in DodgeScene")
        }
        containerPlayer?.isHidden = false
        
        // Gyro data take
        manager.startAccelerometerUpdates()
        
        // Start gyro updates
        startGyro()
        
        self.conductor.playMainMusic()
    }
    
    func enemySpeech(){
        if playerSprite.playerHealth > 0 {
            if let speech = enemyAudioTimes.first {
                if conductor.songPosition + 0.7 >= speech.time {
                    playerSprite.playEnemyAudio(speechPattern: speech.speechPattern)
                    // Remove this task from the list after execution
                    enemyAudioTimes.removeFirst()
                }
            }
        }
    }
    
    func attackPlayer() {
        if playerSprite.playerHealth > 0 {
            if let attack = attackTimes.first {
                if conductor.songPosition + 0.6 >= attack.time {
                    print(conductor.songPosition)
                    print(attack.time)
                    attackBox.attackShow(pan: attack.pan, attackPattern: attack.attackPattern)
                    attackTimes.removeFirst()
                }
            }
        } else if playerSprite.playerHealth == 0 {
            playerSprite.playerHealth = -1
            changeToMissionFailed()
            stopGyro()
            conductor.stopMainMusic()
        }
    }
    
    func changeToMissionFailed(){
        self.removeAllActions()
        let transition = SKTransition.fade(withDuration: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let missionFailedScene = MissionFailedScene(fileNamed: "MissionFailedScene") {
                missionFailedScene.scaleMode = .aspectFill
                missionFailedScene.position = CGPoint(x: 0, y: 0)
                missionFailedScene.songPosition = self.conductor.songPosition // Set the songPosition here
                self.view?.presentScene(missionFailedScene, transition: transition)
            }
        }
    }
    
    func changeToMissionSuccess(){
        self.removeAllActions()
        let transition = SKTransition.fade(withDuration: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let missionSuccessScene = MissionSuccessScene(fileNamed: "MissionSuccessScene") {
                missionSuccessScene.scaleMode = .aspectFill
                missionSuccessScene.position = CGPoint(x: 0, y: 0)
                self.view?.presentScene(missionSuccessScene, transition: transition)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if playerSprite.playerSprite?.isHidden == false {
            conductor.updateSongPosition(currentTime: currentTime)
        }
        
        if conductor.songPosition == 140 {
            changeToMissionSuccess()
        }
        
        enemySpeech()
        attackPlayer()
        if playerSprite.playerInvis > 0 {
            playerSprite.playerInvisibility()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Print the current song position when the screen is tapped
        let formattedSongPosition = String(format: "%.3f", conductor.songPosition)
        print("Current Song Position: \(formattedSongPosition) seconds")

    }
    
    func updateHealthDisplay() {
        for (index, heart) in heartNodes.enumerated() {
            if index < playerSprite.playerHealth {
                heart.texture = SKTexture(imageNamed: "playerHealth")
            } else {
                heart.texture = SKTexture(imageNamed: "playerHealthBlank")
            }
        }
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        print(playerSprite.playerHealth)
        print(playerSprite.playerInvis)
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (CollisionCategory.player.rawValue | CollisionCategory.attack.rawValue) {
            if playerSprite.playerHealth > 0 && playerSprite.playerInvis == 0 {
                playerSprite.playerCollision()
                updateHealthDisplay()
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
                    
                    self?.playerSprite.updatePlayerPosition(accelerationX: CGFloat(-x), accelerationY: CGFloat(y))
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
    
    // TODO: nested function calling
    override func willMove(from view: SKView) {
        // Ensure to stop gyro updates when the scene is removed from the view
        removeAllActions()
        stopGyro()
    }
}
