//
//  IntroScene.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 25/05/24.
//

import SpriteKit
import AVFoundation
import CoreMotion

class IntroScene: SKScene, AVAudioPlayerDelegate {
    let manager = CMMotionManager()
    
    var playerSprite: PlayerSprite!
    var attackBox: AttackBox!
    var conductor = Conductor()
    var containerPlayer:SKSpriteNode?
    var background: SKSpriteNode?
    var backgroundEfekSamping: SKSpriteNode?
    var introAudioPlayer: AVAudioPlayer?
    
    var isTutorialSkippable: Bool = false
    
    private var timer: Timer?
    
    override func didMove(to view: SKView) {
        background = childNode(withName: "backgroundIntro") as? SKSpriteNode
        backgroundEfekSamping = childNode(withName: "backgroundEfekSampingIntro") as? SKSpriteNode
        
        background!.zPosition = 0
        background!.position = CGPoint(x: 0, y: 0)
        background!.size = CGSize (width: 2400, height: 1680)
        backgroundEfekSamping!.zPosition = 1
        backgroundEfekSamping!.position = CGPoint(x: 0, y: 0)
        backgroundEfekSamping!.size = CGSize (width: 2400, height: 1680)
        
        background!.isHidden = false
        backgroundEfekSamping!.isHidden = false
        
        playerSprite = PlayerSprite(scene: self)
        attackBox = AttackBox(scene: self)
        containerPlayer = scene!.childNode(withName: "containerPlayer") as? SKSpriteNode
        
        playIntroAudio()
        let wait = SKAction.wait(forDuration: 30.0)
        let enableTutorialSkip = SKAction.run { [self] in
            isTutorialSkippable = true
        }
        self.run(SKAction.sequence([wait, enableTutorialSkip]))
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == introAudioPlayer {
            // User can now tap the screen to change into IntroScene
            changeToDodgeScene()
        }
    }
    
    func playIntroAudio() {
        if let fileURL = Bundle.main.url(forResource: "StoryIntro", withExtension: "mp3") {
            do {
                introAudioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                introAudioPlayer?.prepareToPlay()
                introAudioPlayer?.volume = 0.7

                introAudioPlayer?.play()
            } catch {
                print("Error playing audio file: \(error.localizedDescription)")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTutorialSkippable {
            changeToDodgeScene()
        }
    }
    
    func changeToDodgeScene(){
        let dodgeScene = DodgeScene(size: self.size)
        dodgeScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(dodgeScene, transition: transition)
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
    
    
    override func willMove(from view: SKView) {
        // Ensure to stop gyro updates when the scene is removed from the view
        stopGyro()
    }
}
