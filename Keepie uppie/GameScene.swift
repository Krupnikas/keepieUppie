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

let MaxFootForce = CGFloat(20000)

let MaxKneeAngle = π * 5 / 6
let MinKneeAngle = π / 3
let KneeAngleDelta = CGFloat(0.0) // π / 30

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
    
    private var floor: SKSpriteNode!

    private var background: SKSpriteNode!
    
    // menu nodes
    private var menuNode: SKNode!
    private var buttonMenu: SKSpriteNode!
    private var buttonRestart: SKSpriteNode!
    private var buttonAd: SKSpriteNode!
    
    // ad nodes
    private var adNode: SKNode!
    private var watchedEnough = false
    
    // continue nodes
    private var continueNode: SKNode!
    private var buttonContinue: SKSpriteNode!
    
    // movement
    private var targetPos : CGPoint?
    private var defautTargetPos : CGPoint?
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
    
    
    // methods
    override func didMove(to view: SKView) {
        // general setup
        physicsWorld.contactDelegate = self
        
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
        defautTargetPos = foot.position
        targetPos = defautTargetPos
        touchNoEffectCircle = hip.size.height * TouchNoEffectSizeCoeff
        
        self.minX = player.position.x + touchNoEffectCircle
        self.maxY = player.position.y // size.height / 2
        
        createBall()
        
        minContactDistance = ballRadius * MinContactMaxDistanceCoeff
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.view?.showsPhysics = true
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
        //To do: physics body here
        
        eye = childNode(withName: "//eye") as? SKSpriteNode
    }
    
    func createLeg() {
        
        hip = childNode(withName: "//hip") as? SKSpriteNode
//        hip.physicsBody = SKPhysicsBody(texture: hip.texture!, size: hip.size)
        hip.physicsBody?.categoryBitMask = PhysicsCategory.Hip
        hip.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        hip.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        let rotationConstraintArm = SKReachConstraints(lowerAngleLimit: CGFloat(0), upperAngleLimit: CGFloat(10))
        hip.reachConstraints = rotationConstraintArm
//        hip.constraints?.append(SKConstraint.zRotation(SKRange(lowerLimit: 0, upperLimit: π / 2)))

        shin = childNode(withName: "//shin") as? SKSpriteNode
//        shin.physicsBody = SKPhysicsBody(texture: shin.texture!, size: shin.size)
        shin.physicsBody?.categoryBitMask = PhysicsCategory.Shin
        shin.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        shin.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
//        shin.constraints?.append(SKConstraint.zRotation(SKRange(lowerLimit: -0.2, upperLimit: 2 * π / 3)))
        
        foot = childNode(withName: "//foot") as? SKSpriteNode
//        foot.physicsBody = SKPhysicsBody(texture: foot.texture!, size: foot.size)
        foot.physicsBody?.categoryBitMask = PhysicsCategory.Foot
        foot.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        foot.physicsBody?.contactTestBitMask = PhysicsCategory.Ball

//        CGPoint(x: 0, y: 0)
        
        
//        let ass = SKPhysicsJointPin.joint(withBodyA: player.physicsBody!,
//                                          bodyB: hip.physicsBody!,
//                                          anchor: hip.position)
//        self.physicsWorld.add(ass)
//
//        let knee = SKPhysicsJointPin.joint(withBodyA: hip.physicsBody!,
//                                           bodyB:  shin.physicsBody!,
//                                           anchor: shin.position)
//        
//        self.physicsWorld.add(knee)
//        
//        let ankle = SKPhysicsJointPin.joint(withBodyA: shin.physicsBody!,
//                                            bodyB: foot.physicsBody!,
//                                            anchor: foot.position)
//        self.physicsWorld.add(ankle)
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
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        ball.physicsBody?.angularVelocity = 0
        ball.position = ballOriginPosition
        
        lastContactPoint = hip.position
        lastContactMaxDistance = (hip.position - ball.position).length()
    }
    
    func onTouchGame(location: CGPoint) {
        let globalMinX = -self.size.width / 2
        let offsetX = CGFloat(50)
        let offsetY = CGFloat(50)
        if location.y < maxY {
            var locationActual = CGPoint(x: max(globalMinX, location.x - offsetX), y: min(self.maxY, location.y + offsetX))
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
                SceneManager.instance.presentMainMenuScene()
            } else if buttonRestart.contains(location) {
                scoreValue = 0
                setStatus(statusNew: SceneStatusGame)
            } else if buttonAd.contains(location) {
                setStatus(statusNew: SceneStatusAd)
            }
        case SceneStatusContinue:
            if buttonContinue.contains(location) {
                setStatus(statusNew: SceneStatusGame)
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
        targetPos = self.defautTargetPos
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        
        let ballPos = ball.position
        let headPos = head.positionInScene
        let eyePos = eye.positionInScene
        
//        print(head.zRotation)
        
        head.zRotation = atan2(ballPos.y - (headPos?.y)!, ballPos.x - (headPos?.x)!) * 0.5 - 0.2
        eye.zRotation = atan2(ballPos.y - (eyePos?.y)!, ballPos.x - (eyePos?.x)!) - head.zRotation
        
        // Called before each frame is rendered
        let footPosX = foot.position.x
        let sizeWidth = self.size.width
        var zRotation = 3 * footPosX / sizeWidth
        zRotation = pow(zRotation, 3)
        if zRotation < MinFootAngle {
            zRotation = MinFootAngle
        } else if zRotation > MaxFootAngle {
            zRotation = MaxFootAngle
        }
        foot.zRotation = zRotation

        // 100 works bad for iphone X
        var force = CGVector(dx: 100 * (targetPos!.x - (foot?.position.x)!),
                            dy: 100 * (targetPos!.y - (foot?.position.y)!))
        if force.length() > MaxFootForce {
            force = force.normalized() * MaxFootForce
        }
        foot.physicsBody?.applyForce(force)

        let hz = hip.zRotation
        let sz = shin.zRotation
        let maxDiff = π - MinKneeAngle
        let minDiff = π - MaxKneeAngle
        let diff = hz - sz
        if diff > maxDiff {
            shin.physicsBody?.applyAngularImpulse(10 * (diff - maxDiff))
//            if diff - maxDiff > KneeAngleDelta {
//                shin.zRotation = hip.zRotation - maxDiff - KneeAngleDelta
//            }
        } else if diff < minDiff {
            shin.physicsBody?.applyAngularImpulse(10 * (diff - minDiff))
        }

        if status != SceneStatusGame {
            return
        }

        if ball.position.x + ballRadius < self.frame.minX ||
            ball.position.x - ballRadius > self.frame.maxX {
            self.setStatus(statusNew: SceneStatusMenu)
        }

        let distance = (ball.position - lastContactPoint).length()
        if distance > lastContactMaxDistance {
            lastContactMaxDistance = distance
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if status != SceneStatusGame {
            return
        }
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Ball | PhysicsCategory.Floor {
            setStatus(statusNew: SceneStatusMenu)
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
        self.scoreLabel.isHidden = false
    }
    
    func hideGame() {
        self.scoreLabel.isHidden = true
    }
    
    // menu
    func showMenu() {
        self.menuNode.isHidden = false
        let isReady = GADRewardBasedVideoAd.sharedInstance().isReady
        if !isReady {
            self.buttonAd.isHidden = true
        } else {
            self.buttonAd.isHidden = false
        }
        if (scoreValue > SceneManager.instance.score) {
            SceneManager.instance.score = scoreValue
        }
    }
    
    func hideMenu() {
        self.menuNode.isHidden = true
    }
    
    // add
    func showAd() {
        self.adNode.isHidden = false
        let isReady = GADRewardBasedVideoAd.sharedInstance().isReady
        guard let controller = self.view?.window?.rootViewController as? GameViewController else {return}
        
        if isReady {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: controller)
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
    }
    
    func adClosed() {
        if watchedEnough {
            setStatus(statusNew: SceneStatusContinue)
        } else {
            scoreValue = 0
            setStatus(statusNew: SceneStatusGame)
        }
    }
}
