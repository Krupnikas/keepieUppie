//
//  GameScene.swift
//  Keepie uppie
//
//  Created by Сергей Крупник on 29.08.2018.
//  Copyright © 2018 Сергей Крупник. All rights reserved.
//

import SpriteKit
import GameplayKit

let MinTimeContactInterval = 0.1
let MinContactMaxDistanceCoeff = CGFloat(4)
let TouchNoEffectSizeCoeff = CGFloat(0.8)

let SceneStatusGame = 0
let SceneStatusMenu = 1
let SceneStatusAd = 2
let SceneStatusContinue = 3

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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // game nodes
    private var gameNode: SKNode!
    private var hip: SKSpriteNode!
    private var shin: SKSpriteNode!
    private var foot: SKSpriteNode!
    private var leg = SKNode()
    
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
    
    // continue nodes
    private var continueNode: SKNode!
    private var buttonContinue: SKSpriteNode!
    
    // movement
    private var targetPos : CGPoint?
    private var defautTargetPos : CGPoint?
    private var touchNoEffectCircle: CGFloat?
    
    private var minX : CGFloat?
    private var maxY : CGFloat?

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
        gameNode = childNode(withName: "game_node")
        background = childNode(withName: "//background") as? SKSpriteNode
        
        floor = childNode(withName: "//floor") as? SKSpriteNode
        floor.physicsBody?.categoryBitMask = PhysicsCategory.Floor
        floor.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        player = childNode(withName: "//player") as? SKSpriteNode
        player.physicsBody?.categoryBitMask = PhysicsCategory.Body
        player.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        player.physicsBody?.contactTestBitMask = PhysicsCategory.None
        
        self.minX = player.position.x
        self.maxY = 0
    
        createLeg()
        defautTargetPos = foot.position
        targetPos = defautTargetPos
        touchNoEffectCircle = hip.size.height * TouchNoEffectSizeCoeff
        
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
        // TODO
        
        // continue setup
        continueNode = childNode(withName: "continue_node")
        buttonContinue = childNode(withName: "//button_continue") as? SKSpriteNode
        
        // status
        setStatus(statusNew: SceneStatusGame)
        
    }
    
    func createLeg() {
        
        leg.name = "leg"
        
        hip = childNode(withName: "//hip") as? SKSpriteNode
        hip.physicsBody?.categoryBitMask = PhysicsCategory.Hip
        hip.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        hip.physicsBody?.contactTestBitMask = PhysicsCategory.Ball

        shin = childNode(withName: "//shin") as? SKSpriteNode
        shin.physicsBody?.categoryBitMask = PhysicsCategory.Shin
        shin.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        shin.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        foot = childNode(withName: "//foot") as? SKSpriteNode
        foot.physicsBody?.categoryBitMask = PhysicsCategory.Foot
        foot.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        foot.physicsBody?.contactTestBitMask = PhysicsCategory.Ball

//        CGPoint(x: 0, y: 0)
        
        
        let ass = SKPhysicsJointPin.joint(withBodyA: hip.physicsBody!,
                                          bodyB: self.physicsBody!,
                                          anchor: player.position)
        self.physicsWorld.add(ass)
        
        let knee = SKPhysicsJointPin.joint(withBodyA: hip.physicsBody!,
                                           bodyB:  shin.physicsBody!,
                                           anchor: CGPoint(x: shin.position.x, y: shin.position.y + shin.size.height / 2))
        
        self.physicsWorld.add(knee)
        
        let ankle = SKPhysicsJointPin.joint(withBodyA: shin.physicsBody!,
                                            bodyB: foot.physicsBody!,
                                            anchor: CGPoint(x: shin.position.x, y: shin.position.y - shin.size.height / 2))
        self.physicsWorld.add(ankle)
    }
    
    func createBall() {
//        let ball = SKSpriteNode(imageNamed: "ball1")
        ball = childNode(withName: "//ball") as? SKSpriteNode
        ballOriginPosition = ball.position
        ballRadius = ball.size.width / 2
//        ball.position = pos
//        ball.name = "ball"

//        ball.setScale((self.size.width / 8) / ball.size.width)
//        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        
        ball.physicsBody?.restitution = 1.1
        ball.physicsBody?.linearDamping = 0.3
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        ball.physicsBody?.restitution = 1.1
        
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Leg | PhysicsCategory.Body | PhysicsCategory.Floor
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Leg | PhysicsCategory.Floor
        
//        self.addChild(ball)
    }
    
    func resetBall() {
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        ball.physicsBody?.angularVelocity = 0
        ball.position = ballOriginPosition
    }
    
    func onTouchGame(location: CGPoint) {
//        let dist = (location - player.position).length()

        targetPos = CGPoint(x: max(self.minX!, location.x - 50), y: min(self.maxY!, location.y + 50))
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
        onTouchGame(location: touches.first!.location(in: self))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        targetPos = self.defautTargetPos
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        foot.zRotation = pow(3 * foot.position.x / self.size.width, 3) + 0.3
        foot.physicsBody?.applyForce(CGVector(dx: 100 * (targetPos!.x - (foot?.position.x)!),
                                               dy: 100 * (targetPos!.y - (foot?.position.y)!)))

        if (hip.zRotation < shin.zRotation + 0.2 )  {
            shin.physicsBody?.applyAngularImpulse(10 * (hip.zRotation - shin.zRotation - 0.2))
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
        resetBall()
        self.scoreLabel.isHidden = false
    }
    
    func hideGame() {
        self.scoreLabel.isHidden = true
    }
    
    // menu
    func showMenu() {
        self.menuNode.isHidden = false
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
    }
    
    func hideAd() {
        self.adNode.isHidden = true
    }
    
    // continue
    func showContinue() {
        self.continueNode.isHidden = false
    }
    
    func hideContinue() {
        self.continueNode.isHidden = true
    }

}
