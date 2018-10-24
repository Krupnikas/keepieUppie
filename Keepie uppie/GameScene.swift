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
    static let Leg:    UInt32 = Hip | Shin | Foot  // 14
    static let Ball:   UInt32 = 0b10000  // 16
    static let Floor:  UInt32 = 0b100000 // 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    // game nodes
    private var gameNode: SKNode!
    private var hip: SKSpriteNode!
    private var shin: SKSpriteNode!
    private var foot: SKSpriteNode!
    private var leg = SKNode()
    
    private var ball: SKSpriteNode!
    
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
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        self.minX = player.position.x
        self.maxY = 0
        self.defautTargetPos = CGPoint(x: self.size.width / 8,
                                       y: -3 * self.size.height/8)
        
        targetPos = self.defautTargetPos
    
        createLeg()
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.view?.showsPhysics = true
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // score setup
        scoreLabel = childNode(withName: "//label_score") as? SKLabelNode
        scoreValue = 0

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
        
        // start
        showGame()
        
    }
    
    func createLeg() {
        
        leg.name = "leg"
        
        hip = childNode(withName: "//hip") as? SKSpriteNode
        hip.physicsBody?.categoryBitMask = PhysicsCategory.Hip
        hip.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        hip.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        let ass = SKPhysicsJointPin.joint(withBodyA: hip.physicsBody!,
                                          bodyB: self.physicsBody!,
                                          anchor: CGPoint(x: hip.position.x,
                                                          y: hip.position.y + 140))
        self.physicsWorld.add(ass)

        shin = childNode(withName: "//shin") as? SKSpriteNode
        shin.physicsBody?.categoryBitMask = PhysicsCategory.Shin
        shin.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        shin.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        let knee = SKPhysicsJointPin.joint(withBodyA: hip.physicsBody!,
                                           bodyB:  shin.physicsBody!,
                                           anchor: CGPoint(x: shin.position.x, y: shin.position.y + 140))
        
        self.physicsWorld.add(knee)
        
        foot = childNode(withName: "//foot") as? SKSpriteNode
        foot.physicsBody?.categoryBitMask = PhysicsCategory.Foot
        foot.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        foot.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        let ankle = SKPhysicsJointPin.joint(withBodyA: shin.physicsBody!,
                                            bodyB: foot.physicsBody!,
                                            anchor: foot.position)
//        CGPoint(x: 0, y: 0)
        self.physicsWorld.add(ankle)
    }
    
    func createBall(atPoint pos : CGPoint) {
        let ball = SKSpriteNode(imageNamed: "ball1")
//        let ball = childNode(withName: "ball") as? SKSpriteNode
        ball.position = pos
        ball.name = "ball"

        ball.setScale((self.size.width / 8) / ball.size.width)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 1.1
        ball.physicsBody?.linearDamping = 0.3
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        ball.physicsBody?.restitution = 1.1
        
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Leg | PhysicsCategory.Body | PhysicsCategory.Floor
        ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
        
        self.addChild(ball)
    }
    
    func resetBall() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        let t = touches.first!.location(in: self)
        targetPos = CGPoint(x: max(self.minX!, t.x - 100), y: min(self.maxY!, t.y + 150))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.isEmpty {
            return
        }

        let t = touches.first!.location(in: self)
        switch status {
        case SceneStatusGame:
            targetPos = CGPoint(x: max(self.minX!, t.x - 100), y: min(self.maxY!, t.y + 150))
        case SceneStatusMenu:
            if buttonMenu.contains(t) {
                SceneManager.instance.presentMainMenuScene()
            } else if buttonRestart.contains(t) {
                scoreValue = 0
                setStatus(statusNew: SceneStatusGame)
            } else if buttonAd.contains(t) {
                setStatus(statusNew: SceneStatusAd)
            }
        case SceneStatusContinue:
            if buttonContinue.contains(t) {
                setStatus(statusNew: SceneStatusGame)
            }
        default:
            return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        targetPos = self.defautTargetPos
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        foot.zRotation = pow(3 * (foot?.position.x)! / self.size.width, 3) + 0.3
        foot.physicsBody?.applyForce(CGVector(dx: 100 * (targetPos!.x - (foot?.position.x)!),
                                               dy: 100 * (targetPos!.y - (foot?.position.y)!)))

        if (hip.zRotation < shin.zRotation + 0.2 )  {
            shin.physicsBody?.applyAngularImpulse(10 * (hip.zRotation - shin.zRotation - 0.2))
        }
        
        if let ball = self.childNode(withName: "ball") {
            if (!self.frame.contains((ball.position))) {
                self.setStatus(statusNew: SceneStatusMenu)
            }
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
        
        if (timeDiff < MinTimeContactInterval) {
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
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.createBall(atPoint: CGPoint(x:  self.size.width / 8 ,
                                             y:  self.size.width / 3 ))
            }, SKAction.wait(forDuration: 10)])))
    }
    
    func hideGame() {
        self.removeAllActions()
    }
    
    // menu
    func showMenu() {
        self.menuNode.isHidden = false
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
