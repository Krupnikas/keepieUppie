//
//  GameScene.swift
//  Keepie uppie
//
//  Created by Сергей Крупник on 29.08.2018.
//  Copyright © 2018 Сергей Крупник. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

let MinTimeContactInterval = 0.1
let MinContactMaxDistanceCoeff = CGFloat(4)
let TouchNoEffectSizeCoeff = CGFloat(0.8)

let SceneStatusGame = 0
let SceneStatusMenu = 1
let SceneStatusAd = 2
let SceneStatusContinue = 3

let MaxFootAngle = π / 2
let MinFootAngle = -π / 5 * 2

let MaxHeadAngle = π / 4
let MinHeadAngle = -π / 4

let MaxEyeAngle = CGFloat(0)
let MinEyeAngle = -π / 4

let DefaultHeadAngle = CGFloat(-π / 8)
let DefaultEyeAngle = CGFloat( -π / 6)

let releasedLinearDamping = CGFloat(5)
let touchedLinearDamping = CGFloat(7)

let MaxFootForce = CGFloat(20000)
let FootForceMultiplyer = CGFloat(10)

let MaxKneeAngle = π * 11 / 12
let MinKneeAngle = π / 3
let KneeAngleDelta = CGFloat(0.0) // π / 30

let menuButtonOffset = CGFloat(30)

//colors
let scoreLableGolwColor = SKColor(red: 255, green: 223, blue: 0, alpha: 255)
let defaultScoreLabelColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
let newRecordScoreLabelColor = UIColor(red: CGFloat(255)/255,
                                       green: CGFloat(86)/255,
                                       blue: CGFloat(0)/255,
                                       alpha: CGFloat(1))

//animations
let pulseScaleDiff = 1.2
let pulseScaleDuration = 1
let upscale = SKAction.scale(to: CGFloat(pulseScaleDiff), duration: TimeInterval(pulseScaleDuration))
let downscale = SKAction.scale(to: 1, duration: TimeInterval(pulseScaleDuration))
let pulse = SKAction.repeatForever(SKAction.sequence([upscale, downscale]))

let scoreScaleFactor = 1.6
let scoreScaleUpDurationWin = 5 // seconds
let scoreScaleUpDuration = 1 // seconds
let scoreScaleDownDuration = 1 // seconds
let scoreOffset = 100
let scoreOffsetWin = 370

let adDelay = SKAction.wait(forDuration: TimeInterval(1.5))  // seconds
let waitWin = SKAction.wait(forDuration: TimeInterval(scoreScaleUpDurationWin / 2))  // seconds
let waitAbit = SKAction.wait(forDuration: TimeInterval(0.1))  // seconds

let scoreUpscaleWin = SKAction.scale(by: CGFloat(scoreScaleFactor), duration: TimeInterval(scoreScaleUpDurationWin))
let scoreMoveToMenuPosWin = SKAction.move(by: CGVector(dx: 0, dy: -scoreOffsetWin), duration: TimeInterval(scoreScaleUpDurationWin))
let fadeInWin = SKAction.fadeAlpha(to:1, duration: TimeInterval(scoreScaleUpDurationWin))

let scoreUpscale = SKAction.scale(by: CGFloat(scoreScaleFactor), duration: TimeInterval(scoreScaleUpDuration))
let scoreDownscale = SKAction.scale(by: 1/CGFloat(scoreScaleFactor), duration: TimeInterval(scoreScaleDownDuration))
let scoreMoveToMenuPos = SKAction.move(by: CGVector(dx: 0, dy: -scoreOffset), duration: TimeInterval(scoreScaleUpDuration))
let scoreMoveToGamePos = SKAction.move(to: CGPoint(x: 0, y: 880), duration: TimeInterval(scoreScaleDownDuration))
let coloriseScoreLabel = SKAction.colorize(with: newRecordScoreLabelColor, colorBlendFactor: CGFloat(1), duration: TimeInterval(0.1))
let decoloriseScoreLabel = SKAction.colorize(with: defaultScoreLabelColor, colorBlendFactor: CGFloat(1), duration: TimeInterval(scoreScaleDownDuration))
let fadeIn = SKAction.fadeAlpha(to:1, duration: TimeInterval(scoreScaleUpDuration))
let fadeOut = SKAction.fadeAlpha(to:0, duration: TimeInterval(CGFloat(scoreScaleDownDuration)))

let hidingAction = SKAction.scale(to: 0, duration: 1)
let showingAction2 = SKAction.scale(to: 2, duration: 1)
let showingAction = SKAction.scale(to: 1, duration: 1)
let showingActionHalf = SKAction.scale(to: 0.5, duration: 1)

struct PhysicsCategory {
    static let None:   UInt32 = 0
    static let Body:   UInt32 = 0b1      // 1
    static let Hip:    UInt32 = 0b10     // 2
    static let Shin:   UInt32 = 0b100    // 4
    static let Foot:   UInt32 = 0b1000   // 8
    static let Leg:    UInt32 = Hip | Shin | Foot
    static let Ball:   UInt32 = 0b10000  // 16
    static let Floor:  UInt32 = 0b100000 // 32
}

extension SKNode {
    var positionInScene:CGPoint? {
        if let scene = scene, let parent = parent {
            return parent.convert(position, to:scene)
        } else {
            return nil
        }
    }
}

func getVisibleScreen(sw: Float, sh: Float, viewWidth: Float, viewHeight: Float) -> CGRect {
    var x: Float = 0
    var y: Float = 0
    
    var sceneWidth = sw
    var sceneHeight = sh
    
    let deviceAspectRatio = viewWidth/viewHeight
    let sceneAspectRatio = sceneWidth/sceneHeight
    
    //If the the device's aspect ratio is smaller than the aspect ratio of the preset scene dimensions, then that would mean that the visible width will need to be calculated
    //as the scene's height has been scaled to match the height of the device's screen. To keep the aspect ratio of the scene this will mean that the width of the scene will extend
    //out from what is visible.
    //The opposite will happen in the device's aspect ratio is larger.
    if deviceAspectRatio < sceneAspectRatio {
        let newSceneWidth: Float = (sceneWidth * viewHeight) / sceneHeight
        let sceneWidthDifference: Float = (newSceneWidth - viewWidth)/2
        let diffPercentageWidth: Float = sceneWidthDifference / (newSceneWidth)
        
        //Increase the x-offset by what isn't visible from the lrft of the scene
        x = diffPercentageWidth * sceneWidth
        //Multipled by 2 because the diffPercentageHeight is only accounts for one side(e.g right or left) not both
        sceneWidth = sceneWidth - (diffPercentageWidth * 2 * sceneWidth)
    } else {
        let newSceneHeight: Float = (sceneHeight * viewWidth) / sceneWidth
        let sceneHeightDifference: Float = (newSceneHeight - viewHeight)/2
        let diffPercentageHeight: Float = fabs(sceneHeightDifference / (newSceneHeight))
        
        //Increase the y-offset by what isn't visible from the bottom of the scene
        y = diffPercentageHeight * sceneHeight
        //Multipled by 2 because the diffPercentageHeight is only accounts for one side(e.g top or bottom) not both
        sceneHeight = sceneHeight - (diffPercentageHeight * 2 * sceneHeight)
    }
    
    let visibleScreenOffset = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(sceneWidth), height: CGFloat(sceneHeight))
    return visibleScreenOffset
}

class GameScene: SKScene, SKPhysicsContactDelegate, AdScene {
    
    // game nodes
    private var gameNode: SKNode!
    private var gravity_node: SKSpriteNode!
    private var hip: SKSpriteNode!
    private var shin: SKSpriteNode!
    private var foot: SKSpriteNode!
    
    private var head: SKSpriteNode!
    private var eye: SKSpriteNode!
    
    private var ball: SKSpriteNode!
    private var ballOriginPosition: CGPoint!
    private var ballRadius: CGFloat!
    private var minContactDistance: CGFloat!
    
    private var player: SKSpriteNode!
    
    private var recordNode: SKLabelNode!
    
    private var floor: SKSpriteNode!

    private var background: SKSpriteNode!
    
    // menu nodes
    private var menuNode: SKNode!
    private var buttonMenu: SKSpriteNode!
    private var buttonRestart: SKSpriteNode!
    private var buttonAd: SKSpriteNode!
    
    private var activeButton: SKNode!
    
    // ad nodes
    private var adNode: SKNode!
    private var watchedEnough = false
    
    // continue nodes
    private var continueNode: SKNode!
    private var buttonContinue: SKSpriteNode!
    
    // movement
    private var targetPos : CGPoint?
    var defautTargetPos = CGPoint()
    private var touchNoEffectCircle: CGFloat!
    
    private var minX : CGFloat!
    private var maxY : CGFloat!

    // score
    private var scoreLabel: SKLabelNode!
    private var scoreValue: Int = 0 {
        didSet {
            scoreLabel.text = String(self.scoreValue)
        }
    }
    
    private var lastContactTime = Date()
    private var lastContactPoint: CGPoint!
    private var lastContactMaxDistance: CGFloat!
    
    // game status
    private var status = SceneStatusGame
    private var adShown = false
    
    //sounds
    let kickSounds = [
        SKAction.playSoundFileNamed("sounds/kick0", waitForCompletion: false),
        SKAction.playSoundFileNamed("sounds/kick1", waitForCompletion: false)]
    
    let whistleSound = SKAction.group([
        SKAction.playSoundFileNamed("sounds/whistle", waitForCompletion: false),
        SKAction.changeVolume(to: 0.3, duration: 0.3)])
    
    let newRecordSound = SKAction.playSoundFileNamed("sounds/tada", waitForCompletion: false)
    let winSound = SKAction.playSoundFileNamed("sounds/win", waitForCompletion: false)
    let looseSound = SKAction.playSoundFileNamed("sounds/oh", waitForCompletion: false)
        
    // methods
    override func didMove(to view: SKView) {
        // general setup
        physicsWorld.contactDelegate = self
        
        //animations
        upscale.timingMode = .easeInEaseOut
        downscale.timingMode = .easeInEaseOut
        scoreUpscale.timingMode = .easeInEaseOut
        scoreDownscale.timingMode = .easeInEaseOut
        scoreMoveToMenuPos.timingMode = .easeInEaseOut
        scoreMoveToGamePos.timingMode = .easeInEaseOut
        hidingAction.timingMode = .easeInEaseOut
        showingAction2.timingMode = .easeInEaseOut
        showingActionHalf.timingMode = .easeInEaseOut
        coloriseScoreLabel.timingMode = .easeInEaseOut
        decoloriseScoreLabel.timingMode = .easeInEaseOut
        fadeOut.timingMode = .easeInEaseOut
        fadeIn.timingMode = .easeInEaseOut
        showingAction.timingMode = .easeInEaseOut
        
        scoreUpscaleWin.timingMode = .easeInEaseOut
        scoreMoveToMenuPosWin.timingMode = .easeInEaseOut
        fadeInWin.timingMode = .easeInEaseOut
        
        // game setup
        gameNode = childNode(withName: "//game_node")
        
        gravity_node = childNode(withName: "//gravity_node") as? SKSpriteNode
        
        background = childNode(withName: "//background") as? SKSpriteNode
        
        floor = childNode(withName: "//floor") as? SKSpriteNode
        floor.physicsBody?.categoryBitMask = PhysicsCategory.Floor
        floor.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        player = childNode(withName: "//player") as? SKSpriteNode
        player.physicsBody?.categoryBitMask = PhysicsCategory.Body
        player.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        player.physicsBody?.contactTestBitMask = PhysicsCategory.None
        
        createHead()
        createLeg()
        
        touchNoEffectCircle = hip.size.height * TouchNoEffectSizeCoeff
        
        self.minX = player.position.x + touchNoEffectCircle
        self.maxY = player.position.y // size.height / 2
        
        createBall()
        self.defautTargetPos = CGPoint(x: (ball.positionInScene?.x)!, y: -self.size.height * 4 / 12)
        targetPos = self.defautTargetPos
        
        minContactDistance = ballRadius * MinContactMaxDistanceCoeff
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame) // DEBUG
//        self.view?.showsPhysics = true
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // score setup
        scoreLabel = childNode(withName: "//label_score") as? SKLabelNode
        scoreValue = 0
        
        lastContactPoint = hip.position
        lastContactMaxDistance = (hip.position - ball.position).length()

        // menu setup
        menuNode = childNode(withName: "menu_node")
        buttonMenu = childNode(withName: "//button_menu") as? SKSpriteNode
        buttonRestart = childNode(withName: "//button_restart") as? SKSpriteNode
        buttonAd = childNode(withName: "//button_ad") as? SKSpriteNode
        recordNode = childNode(withName: "//record") as? SKLabelNode
        recordNode.setScale(0)
        
        buttonMenu.isHidden = false
        buttonMenu.position = CGPoint(x: self.frame.minX + buttonMenu.size.width / 2 + menuButtonOffset, // aligning bottom left
                                      y: -getVisibleScreen(
                                        sw: Float(self.scene!.frame.width),
                                        sh: Float(self.scene!.frame.height),
                                        viewWidth: Float(self.view!.frame.width),
                                        viewHeight: Float(self.view!.frame.height)).height / 2
                                        + buttonMenu.size.height/2 + menuButtonOffset)
        buttonMenu.setScale(0)
        
        // ad setup
        adNode = childNode(withName: "ad_node")
        
        // continue setup
        continueNode = childNode(withName: "continue_node")
        buttonContinue = childNode(withName: "//button_continue") as? SKSpriteNode
        
        // status
        setStatus(statusNew: SceneStatusGame)
        
    }
    
    func createHead() {
        head = childNode(withName: "//head") as? SKSpriteNode
//        head.physicsBody = SKPhysicsBody(texture: head.texture!, size: head.size)
        head.physicsBody?.affectedByGravity = false
        head.physicsBody?.isDynamic = true
        head.physicsBody?.allowsRotation = true

        head.physicsBody?.categoryBitMask = PhysicsCategory.Body
        head.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        head.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        let neck = SKPhysicsJointPin.joint(withBodyA: player.physicsBody!,
                                          bodyB: head.physicsBody!,
                                          anchor: CGPoint(x: -370, y: 837))
        self.physicsWorld.add(neck)
        print(head.physicsBody!.affectedByGravity)
        
        eye = childNode(withName: "//eye") as? SKSpriteNode
    }
    
    func createLeg() {
        
        hip = childNode(withName: "//hip") as? SKSpriteNode
//        hip.physicsBody = SKPhysicsBody(texture: hip.texture!, size: hip.size)
        hip.physicsBody?.affectedByGravity = false
        hip.physicsBody?.linearDamping = 1
        hip.physicsBody?.categoryBitMask = PhysicsCategory.Hip
        hip.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        hip.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        let rotationConstraintArm = SKReachConstraints(lowerAngleLimit: CGFloat(0), upperAngleLimit: CGFloat(10))
        hip.reachConstraints = rotationConstraintArm
        //        hip.constraints?.append(SKConstraint.zRotation(SKRange(lowerLimit: 0, upperLimit: π / 2)))
        
        shin = childNode(withName: "//shin") as? SKSpriteNode
//        shin.physicsBody = SKPhysicsBody(texture: shin.texture!, size: shin.size)
        shin.physicsBody?.affectedByGravity = false
        shin.physicsBody?.linearDamping = 1
        shin.physicsBody?.categoryBitMask = PhysicsCategory.Shin
        shin.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        shin.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        //        shin.constraints?.append(SKConstraint.zRotation(SKRange(lowerLimit: -0.2, upperLimit: 2 * π / 3)))
        
        foot = childNode(withName: "//foot") as? SKSpriteNode
//        foot.physicsBody = SKPhysicsBody(texture: foot.texture!, size: foot.size)
        foot.physicsBody?.affectedByGravity = false
        foot.physicsBody?.allowsRotation = false
        foot.physicsBody?.linearDamping = 2
        foot.physicsBody?.angularDamping = 10
        foot.physicsBody?.categoryBitMask = PhysicsCategory.Foot
        foot.physicsBody?.collisionBitMask = PhysicsCategory.Ball // | PhysicsCategory.Floor
        foot.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        foot.physicsBody?.fieldBitMask = PhysicsCategory.Foot
        //        CGPoint(x: 0, y: 0)
        
        let ass = SKPhysicsJointPin.joint(withBodyA: player.physicsBody!,
                                          bodyB: hip.physicsBody!,
                                          anchor: CGPoint(x: -440, y: 0))
        self.physicsWorld.add(ass)
        
        let knee = SKPhysicsJointPin.joint(withBodyA: hip.physicsBody!,
                                           bodyB:  shin.physicsBody!,
                                           anchor: CGPoint(x: -440, y: -425))
        
        self.physicsWorld.add(knee)
        
        let ankle = SKPhysicsJointPin.joint(withBodyA: shin.physicsBody!,
                                            bodyB: foot.physicsBody!,
                                            anchor: CGPoint(x: -425, y:-810))
        self.physicsWorld.add(ankle)
        
        // Measured. Depend on default pos. DON'T MOVE THE BALL!! Or change this values
        hip.position = CGPoint(x: -311.99462890625, y: -182.842864990234)
        hip.zRotation = 0.787243187427521
        shin.position = CGPoint(x: -44.5474967956543, y: -489.776184082031)
        shin.zRotation = 0.529626190662384
        foot.position = CGPoint(x: 216.634857177734, y: -731.635803222656)
        foot.zRotation = 0.0424571447074413
    }
    
    func createBall() {
//        let ball = SKSpriteNode(imageNamed: "ball1")
        ball = childNode(withName: "//ball") as? SKSpriteNode
        ballOriginPosition = ball.position
        ballRadius = ball.size.width / 2
//        ball.position = pos
//        ball.name = "ball"

//        ball.setScale((self.size.width / 8) / ball.size.width)
//        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 3)
//        ball.physicsBody?.fieldBitMask = 0
        
        
        ball.physicsBody?.restitution = 1.1
        ball.physicsBody?.linearDamping = 0.3
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        ball.physicsBody?.restitution = 1.1
        
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Leg | PhysicsCategory.Body | PhysicsCategory.Floor
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Leg | PhysicsCategory.Floor
        
//        self.addChild(ball)
    }
    
    func resetGame() {
        
        self.run(whistleSound)
        
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        ball.physicsBody?.angularVelocity = 0
        ball.position = ballOriginPosition
        
        lastContactPoint = hip.position
        lastContactMaxDistance = (hip.position - ball.position).length()
        
        print("Game reseted")
        adShown = false
    }
    
    func onTouchGame(location: CGPoint) {
        
        hip.physicsBody?.linearDamping = touchedLinearDamping
        shin.physicsBody?.linearDamping = touchedLinearDamping
        foot.physicsBody?.linearDamping = touchedLinearDamping
        
        let globalMinX = -self.size.width / 2
        let offsetX = CGFloat(50)
        let offsetY = CGFloat(50)
        
        if location.y < maxY {
            var locationActual = CGPoint(x: max(globalMinX, location.x - offsetX),
                                         y: min(self.maxY, location.y + offsetX))
            let vect = locationActual - player.position
            if vect.length() <= touchNoEffectCircle {
                locationActual = player.position + vect.normalized() * touchNoEffectCircle
                if locationActual.x < globalMinX + offsetX {
                    locationActual.x = globalMinX + offsetX
                    locationActual.y = -touchNoEffectCircle
                } else if locationActual.x < player.position.x {
                    locationActual.y = -touchNoEffectCircle
                }
                
                targetPos = locationActual
                return
            }
            
            targetPos = locationActual
            return
        }
        
        let x = max(self.minX, location.x - offsetX)
        let xWithOffset = x - (player.position.x + touchNoEffectCircle)
        let fy = 0.5 * xWithOffset + player.position.y + offsetY
        
        targetPos = CGPoint(x: x, y: min(fy, location.y + offsetY))
    }
    
    func onTouch(location: CGPoint) {
        switch status {
        case SceneStatusGame:
            onTouchGame(location: location)
        case SceneStatusMenu:
            if buttonMenu.contains(location) {
                activeButton = buttonMenu
            } else if buttonRestart.contains(location) {
                activeButton = buttonRestart
            } else if buttonAd.contains(location) {
                activeButton = buttonAd
            }
        case SceneStatusContinue:
            if buttonContinue.contains(location) {
                activeButton = buttonContinue
            }
        default:
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.isEmpty {
            return
        }
        
        onTouch(location: touches.first!.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.isEmpty {
            return
        }
        
        if status != SceneStatusGame {
            return
        }
        
        onTouchGame(location: touches.first!.location(in: self))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self)
        switch status {
        case SceneStatusGame:
            hip.physicsBody?.linearDamping = releasedLinearDamping
            shin.physicsBody?.linearDamping = releasedLinearDamping
            foot.physicsBody?.linearDamping = releasedLinearDamping
            targetPos = defautTargetPos
        case SceneStatusMenu:
            if buttonMenu.contains(location!) && activeButton == buttonMenu {
                SceneManager.instance.presentMainMenuScene()
            } else if buttonRestart.contains(location!) && activeButton == buttonRestart{
                scoreValue = 0
                setStatus(statusNew: SceneStatusGame)
            } else if buttonAd.contains(location!) && activeButton == buttonAd {
                setStatus(statusNew: SceneStatusAd)
            }
        case SceneStatusContinue:
            if buttonContinue.contains(location!) && activeButton == buttonContinue {
                setStatus(statusNew: SceneStatusGame)
                adShown = true
            }
        default:
            return
        }
        activeButton = nil 
    }
    
    override func update(_ currentTime: TimeInterval) {

//        print(buttonAd.xScale)
//        print("Hip:", hip.position, hip.zRotation)
//        print("Shin:", shin.position, shin.zRotation)
//        print("Foot:", foot.position, foot.zRotation)
//        print(head.position)
    
        // Called before each frame is rendered
        let footPosX = foot.position.x
        let sizeWidth = self.size.width
        var zRotation = 2 * footPosX / sizeWidth
        zRotation = pow(zRotation, 3)
        if zRotation < MinFootAngle {
            zRotation = MinFootAngle
        } else if zRotation > MaxFootAngle {
            zRotation = MaxFootAngle
        }
        foot.zRotation = zRotation

        // 100 works bad for iphone X
        var force = CGVector(dx: FootForceMultiplyer * (targetPos!.x - (foot?.position.x)!),
                            dy: FootForceMultiplyer * (targetPos!.y - (foot?.position.y)!))
        if force.length() > MaxFootForce {
            force = force.normalized() * MaxFootForce
        }
        if targetPos == defautTargetPos
        {
            foot.physicsBody?.applyForce(force)
        }
        else
        {
            foot.physicsBody?.velocity = force
        }

        let hz = hip.zRotation
        let sz = shin.zRotation
        let maxDiff = π - MinKneeAngle
        let minDiff = π - MaxKneeAngle
        let diff = hz - sz
//        print(diff)
        if diff > maxDiff {
            shin.physicsBody?.applyAngularImpulse(20 * (diff - maxDiff))
//            hip.physicsBody?.applyAngularImpulse(-30 * (diff - maxDiff))
//            if diff - maxDiff > KneeAngleDelta {
//                shin.zRotation = hip.zRotation - maxDiff - KneeAngleDelta
//            }
        } else if diff < minDiff {
            shin.physicsBody?.applyAngularImpulse(20 * (diff - minDiff))
//            hip.physicsBody?.applyAngularImpulse(-30 * (diff - maxDiff))
        }

        if diff < 0 {
            shin.physicsBody?.angularVelocity = 60 * (diff)
        }

        let ballPos = ball.position
        let headPos = head.positionInScene
        let eyePos = eye.positionInScene

        let hzr = atan2(ballPos.y - (headPos?.y)!, ballPos.x - (headPos?.x)!) * 0.5 - 0.1

        var targerHeadAngle = hzr

        if hzr > MaxHeadAngle {
            targerHeadAngle = MaxHeadAngle
        } else if hzr < MinHeadAngle {
            targerHeadAngle = MinHeadAngle
        }

        if (ball.position.x < self.frame.minX ||  // Possible wrong state fix
            ball.position.x - ballRadius > self.frame.maxX) && buttonRestart.isHidden {
            loose();
        }

        if self.status != SceneStatusGame {
            targerHeadAngle = DefaultHeadAngle
            head.physicsBody?.angularVelocity = 1 * (targerHeadAngle - head.zRotation)
            return
        }

        if head.zRotation != targerHeadAngle {
            head.physicsBody?.angularVelocity = 10 * (targerHeadAngle - head.zRotation)
        }

        let ezr = atan2(ballPos.y - (eyePos?.y)!, ballPos.x - (eyePos?.x)!) - head.zRotation
        if ezr > MaxEyeAngle {
            eye.zRotation = MaxEyeAngle
        } else if ezr < MinEyeAngle {
            eye.zRotation = MinEyeAngle
        } else {
            eye.zRotation = ezr
        }

        if ball.position.x < (head.positionInScene?.x)! ||
            ball.position.x - ballRadius > self.frame.maxX {
            loose();
        }

        let distance = (ball.position - lastContactPoint).length()
        if distance > lastContactMaxDistance {
            lastContactMaxDistance = distance
        }
    }

    func loose() {
        print("Looser!")
        self.setStatus(statusNew: SceneStatusMenu)
        
        let zero = CGVector(dx: 0, dy: 0)
        hip.physicsBody?.velocity = zero
        shin.physicsBody?.velocity = zero
        foot.physicsBody?.velocity = zero
        
        targetPos = defautTargetPos
        
        head.physicsBody?.angularVelocity = 0

        let eyeAction = SKAction .rotate(toAngle: DefaultEyeAngle, duration: 0.8)
        eyeAction.timingMode = .easeInEaseOut
        eye.run(eyeAction)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let soundIndex = Int(arc4random_uniform(UInt32(kickSounds.count)))
        self.run(kickSounds[soundIndex])
        
        if status != SceneStatusGame {
            return
        }
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Ball | PhysicsCategory.Floor {
            loose()
            return
        }
        
        let now = Date()
        let timeDiff = Double(now.timeIntervalSince1970 - lastContactTime.timeIntervalSince1970)
        lastContactTime = now
        
        let maxDist = lastContactMaxDistance!
        lastContactPoint = contact.contactPoint
        lastContactMaxDistance = ballRadius
        
        if (timeDiff < MinTimeContactInterval || maxDist < minContactDistance) {
            return
        }
    
        scoreValue += 1
        if (scoreValue == SceneManager.instance.score + 1) {
            
            scoreLabel.run(coloriseScoreLabel)
            self.run(newRecordSound)
            print("New record!")
//            scoreLabel.fontColor = newRecordScoreLabelColor
        }
    }
    
    // scene status   
    func setStatus(statusNew: Int) {
        switch status {
        case SceneStatusGame:
            hideGame()
        case SceneStatusMenu:
            hideMenu()
        case SceneStatusAd:
            hideAd()
        case SceneStatusContinue:
            hideContinue()
        default:
            print("Invalud current status: \(status)")
        }
        
        switch statusNew {
        case SceneStatusGame:
            showGame()
        case SceneStatusMenu:
            showMenu()
        case SceneStatusAd:
            showAd()
        case SceneStatusContinue:
            showContinue()
        default:
            print("Invalud new status: \(statusNew)")
        }
        
        status = statusNew
    }
    
    // game
    func showGame() {
        resetGame()
//        self.scoreLabel.isHidden = false
    }
    
    func hideGame() {
//        self.scoreLabel.isHidden = true
    }
    
    // menu
    func showMenu() {
        
        var wait = waitAbit
        
        if (scoreValue > SceneManager.instance.score)
        {
            wait = waitWin
            self.run(winSound)
            scoreLabel.run(scoreUpscaleWin)
            scoreLabel.run(scoreMoveToMenuPosWin)
            scoreLabel.childNode(withName: "win_crown")?.run(fadeInWin)
        }
        else
        {
            scoreLabel.run(scoreUpscale)
            scoreLabel.run(scoreMoveToMenuPos)
            recordNode.text = String(SceneManager.instance.score)
            recordNode.run(showingAction)
            self.run(looseSound)
        }
        
        buttonAd.setScale(1)
        
        buttonRestart.setScale(0)
        buttonAd.setScale(0)
        buttonMenu.setScale(0)
        
        self.menuNode.isHidden = false
        let isReady = GADRewardBasedVideoAd.sharedInstance().isReady
        print("Ad shown: ", self.adShown)
        if !isReady || self.adShown {
            self.buttonAd.isHidden = true
            buttonRestart.position = CGPoint(x: 0, y: 0)
            buttonRestart.run(SKAction.sequence([wait, showingAction2]))
            buttonMenu.run(SKAction.sequence([wait, showingActionHalf]))
            print("hidden")
        } else {
            self.buttonAd.isHidden = false
            buttonRestart.position = CGPoint(x: 0, y: -600)
            buttonAd.run(SKAction.sequence([wait, pulse]))
            buttonRestart.run(SKAction.sequence([wait, adDelay, showingAction2]))
            buttonMenu.run(SKAction.sequence([wait, adDelay, showingActionHalf]))
        }
        if (scoreValue > SceneManager.instance.score) {
            SceneManager.instance.score = scoreValue
        }
    }
    
    func hideMenu() {
        scoreLabel.childNode(withName: "win_crown")?.run(fadeOut)
        scoreLabel.run(scoreDownscale)
        scoreLabel.run(scoreMoveToGamePos)
        if (scoreValue == 0) {
            scoreLabel.run(decoloriseScoreLabel)
        }
//        scoreLabel.fontColor = defaultScoreLabelColor
        recordNode.run(hidingAction)
        buttonRestart.run(hidingAction)
        buttonAd.removeAllActions()
        buttonAd.run(hidingAction)
        buttonMenu.run(hidingAction)
//        self.menuNode.isHidden = true
    }
    
    // add
    func showAd() {
        menuNode.isHidden = true
        adNode.isHidden = false
        
//        let isReady = GADRewardBasedVideoAd.sharedInstance().isReady
        let isReady = true
        
        guard let controller = self.view?.window?.rootViewController as? GameViewController else {return}
        
        if isReady {
            print("going to show ad")
            
//            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: controller)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAd"), object: nil)

            
            print("ad shown")
            self.adShown = true
        } else {
            print("add was not ready:(")
        }
    }
    
    func hideAd() {
        self.adNode.isHidden = true
    }
    
    // continue
    func showContinue() {
        self.continueNode.isHidden = false
        self.scoreLabel.isHidden = false
    }
    
    func hideContinue() {
        self.continueNode.isHidden = true
    }


    // ad scene methods
    func adStarted() {
        watchedEnough = false
    }
    
    func adWatchedEnough() {
        watchedEnough = true
        adShown = true
    }
    
    func adClosed() {
        if watchedEnough {
            setStatus(statusNew: SceneStatusContinue)
        } else {
            scoreValue = 0
            scoreLabel.fontColor = defaultScoreLabelColor
            setStatus(statusNew: SceneStatusGame)
            adShown = true
        }
    }
}
