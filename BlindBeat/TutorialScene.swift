//
//  Tutorial.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 25/05/24.
//

import SpriteKit
import AVFoundation
import CoreMotion

class TutorialScene: SKScene, AVAudioPlayerDelegate {
    var playerSprite: PlayerSprite!
    var playerSpriteNode: SKSpriteNode!
    var currentPlayerPosition: CGPoint = CGPoint(x: 0, y: -400)
    var instructionLabel: SKLabelNode!
    var motionManager: CMMotionManager!
    var audioPlayer: AVAudioPlayer?
    var introBGPlayer: AVAudioPlayer?
    var timer: Timer?
    var calibrationCompleted = false
    
    var isScreenTappable = false
    
    var background = SKSpriteNode(imageNamed: "background")
    var beginScreen : SKSpriteNode?
    var teksInstruksi1 : SKSpriteNode?
    var teksInstruksi2 : SKSpriteNode?
    var instruksi3Completed: Bool = false
    var currentlyStep: Int = 0
    
    override func didMove(to view: SKView) {
        beginScreen = childNode(withName: "beginScreen") as? SKSpriteNode
        beginScreen?.position = CGPoint(x: 0, y: 0)
        teksInstruksi1 = childNode(withName: "//teksInstruksi1") as? SKSpriteNode
        teksInstruksi2 = childNode(withName: "//teksInstruksi2") as? SKSpriteNode
        teksInstruksi1!.isHidden = true
        teksInstruksi2!.isHidden = true
        beginScreen?.isHidden = true
        
        background.zPosition = 0
        background.position = CGPoint(x: 0, y: 0)
        background.size = CGSize (width: 2400, height: 2000)
        
        playerSprite = PlayerSprite(scene: self)
        playerSprite.playerShow()
        playerSpriteNode = playerSprite.playerSprite
        
        instructionLabel = SKLabelNode(fontNamed: "Helvetica")
        instructionLabel.fontSize = 24
        instructionLabel.position = CGPoint(x: 0, y: 100)
        addChild(instructionLabel)
        
        background.zPosition = 0
        background.position = CGPoint(x: 0, y: 0)
        background.size = CGSize (width: 2400, height: 1680)
        addChild(background)
        
        motionManager = CMMotionManager()
        showStep1()
    }
    
    func showStep1() {
        currentlyStep = 1
        let waitLoad = SKAction.wait(forDuration: 3.0)
        let wait = SKAction.wait(forDuration: 7.0)
        let playFirstAudio = SKAction.run { [self] in
            playAudio(named: "Instruksi1")
            self.teksInstruksi1!.isHidden = false
            self.teksInstruksi1!.zPosition = 1
        }
        let startGyro = SKAction.run { [self] in
            isScreenTappable = true
            self.startGyro()
        }
        self.run(SKAction.sequence([waitLoad, playFirstAudio, wait, startGyro]))
    }
    
    func updatePlayerPosition(accelerationX: CGFloat, accelerationY: CGFloat) {
        let xsensitivity: CGFloat = 350.0
        let ysensitivity: CGFloat = 250.0
        
        let newPositionX = playerSpriteNode.position.x + accelerationX * xsensitivity
        let newPositionY = playerSpriteNode.position.y + accelerationY * ysensitivity
        
        let clampedPositionX = clamp(value: newPositionX, lower: -640, upper: 640)
        let clampedPositionY = clamp(value: newPositionY, lower: -640, upper: 640)
        
        playerSpriteNode.position = CGPoint(x: clampedPositionX, y: clampedPositionY)
        currentPlayerPosition = playerSpriteNode.position
        
        let middleArea = CGRect(x: frame.midX - 100, y: frame.midY - 100, width: 200, height: 200)
        if middleArea.contains(playerSpriteNode.position) && !calibrationCompleted {
            showStep2()
        }
    }
    
    func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
    
    func showStep2() {
        currentlyStep = 2
        self.calibrationCompleted = true
        self.teksInstruksi1!.isHidden = true
        self.teksInstruksi2!.isHidden = false
        self.teksInstruksi2!.zPosition = 1

        playAudio(named: "Instruksi2")
        let wait = SKAction.wait(forDuration: 7.0)
        let showStep3 = SKAction.run {
            self.showStep3()
        }
        self.run(SKAction.sequence([wait, showStep3]))
    }
    
    func showStep3() {
        currentlyStep = 3
        stopGyro()
        self.teksInstruksi2!.isHidden = true
        
        playerSpriteNode.isHidden = true
        beginScreen?.isHidden = false
        beginScreen?.zPosition = 1
        
        beginScreen?.alpha = 0.0
        
        let fadeInAction = SKAction.fadeIn(withDuration: 2.0)
        
        beginScreen?.run(fadeInAction)
        playIntroBGMusic()
        
        let wait = SKAction.wait(forDuration: 3.0)
        let waitUntilAudio3Finishes = SKAction.wait(forDuration: 5.0)
        let playAudio3 = SKAction.run { [self] in
            playAudio(named: "Instruksi3")
        }
        let toggleInstruksi3 = SKAction.run { [self] in
            instruksi3Completed = true
        }
        self.run(SKAction.sequence([wait, playAudio3, waitUntilAudio3Finishes, toggleInstruksi3]))
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isScreenTappable && currentlyStep == 1 {
            showStep2()
        }
        if instruksi3Completed {
            changeToIntroScene()
        }
    }
    
    func changeToIntroScene() {
        let introScene = IntroScene(size: self.size)
        introScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(introScene, transition: transition)
    }
    
    func playAudio(named fileName: String) {
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = 0.7
                
                audioPlayer?.play()
            } catch {
                print("Error playing audio file: \(error.localizedDescription)")
            }
        }
    }
    
    func playIntroBGMusic() {
        if let fileURL = Bundle.main.url(forResource: "waitscreen-music", withExtension: "mp3") {
            do {
                introBGPlayer = try AVAudioPlayer(contentsOf: fileURL)
                introBGPlayer?.numberOfLoops = -1 // Loop indefinitely
                introBGPlayer?.prepareToPlay()
                introBGPlayer?.volume = 0.5
                
                introBGPlayer?.play()
            } catch {
                print("Error playing intro background music: \(error.localizedDescription)")
            }
        }
    }
    
    func startGyro() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 50
            motionManager.startAccelerometerUpdates()
            
            timer = Timer(fire: Date(), interval: (1.0 / 50.0), repeats: true) { [weak self] timer in
                if let data = self?.motionManager.accelerometerData {
                    let x = data.acceleration.y
                    let y = data.acceleration.x
                    
                    self?.updatePlayerPosition(accelerationX: CGFloat(-x), accelerationY: CGFloat(y))
                }
            }
            
            RunLoop.current.add(timer!, forMode: .default)
        }
    }
    
    func stopGyro() {
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // Stop accelerometer updates
        motionManager.stopAccelerometerUpdates()
    }
    
    override func willMove(from view: SKView) {
        introBGPlayer?.stop()
    }
}

