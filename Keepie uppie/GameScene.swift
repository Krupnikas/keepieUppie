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

struct PhysicsCategory {
    static let None:   UInt32 = 0
    static let Body:   UInt32 = 0b01  // 1
    static let Leg:    UInt32 = 0b10  // 2
    static let Ball:   UInt32 = 0b100 // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var leg : SKSpriteNode?
    private var targetPos : CGPoint?
    
    private var defautTargetPos : CGPoint?
    
    private var minX : CGFloat?
    private var maxY : CGFloat?
    
    var background = SKSpriteNode(imageNamed: "background.jpg")

    // score
    private var scoreLabel: SKLabelNode!
    private var scoreValue: Int = 0 {
        didSet {
            scoreLabel.text = String(self.scoreValue)
        }
    }
    
    private var lastContactTime = Date()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        background.setScale(self.size.height / background.size.height)
        background.zPosition = -1
        self.addChild(background)
        
        let player = SKSpriteNode(imageNamed: "player")
        player.setScale(2)
//        player.physicsBody = SKPhysicsBody(texture: player.texture!,
//                                           size: player.size)
        player.position = CGPoint(x: -3 * self.size.width / 8, y: 0)
        player.zPosition = 3
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.linearDamping = 10
        player.physicsBody?.affectedByGravity=false
        player.physicsBody?.categoryBitMask = PhysicsCategory.Body
        player.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
//        player.physicsBody?.isDynamic=false
        self.addChild(player)
        
        self.minX = player.position.x
        self.maxY = 0
        self.defautTargetPos = CGPoint(x: self.size.width / 8,
                                       y: -3 * self.size.height/8)
        
        targetPos = self.defautTargetPos
    
        createLeg()
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.createBall(atPoint: CGPoint(x:  self.size.width / 8 ,
                                        y:  self.size.width / 3 ))
            }, SKAction.wait(forDuration: 10)])))
        
        
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
//        self.view?.showsPhysics = true
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // score setup
        scoreLabel = SKLabelNode()
//        scoreLabel.position = CGPoint(x: self.size.width / 2, y: 0)
        scoreLabel.position = CGPoint(x: 0, y: self.size.height * 2 / 5)
        scoreLabel.fontSize = 80
        scoreLabel.zPosition = 4
        scoreLabel.text = "123"
        self.addChild(scoreLabel)
        
        scoreValue = 0
    }
    
    func createLeg() {
        let w = self.size.width
        
        let leg = SKNode()
        leg.name = "leg"
        self.addChild(leg)
    
        
        var hip  : SKSpriteNode
        var shin : SKSpriteNode
        var foot : SKSpriteNode
        
        hip  = SKSpriteNode(imageNamed: "hip")
        hip.position = CGPoint(x: -3 * w / 8, y: -hip.size.height/2)
        hip.name = "hip"
        hip.physicsBody = SKPhysicsBody(texture: hip.texture!, size: hip.size)
        hip.physicsBody?.linearDamping = 10
        hip.physicsBody?.affectedByGravity=false
        hip.physicsBody?.categoryBitMask = PhysicsCategory.Leg
        hip.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        hip.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        leg.addChild(hip)
        
        let ass = SKPhysicsJointPin.joint(withBodyA: hip.physicsBody!,
                                          bodyB: self.physicsBody!,
                                          anchor: CGPoint(x: hip.position.x,
                                                          y: hip.position.y + 140))
        self.physicsWorld.add(ass)

        shin  = SKSpriteNode(imageNamed: "shin")
        
        let offset = CGFloat(70.0)
        shin.name = "shin"
        shin.position = CGPoint(x: hip.position.x + 10,
                                y: hip.position.y + offset - hip.size.height)
        shin.setScale(0.9)
        shin.physicsBody = SKPhysicsBody(texture: shin.texture!, size: shin.size)
        shin.physicsBody?.linearDamping = 10
        shin.physicsBody?.affectedByGravity=false
        shin.physicsBody?.categoryBitMask = PhysicsCategory.Leg
        shin.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        shin.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        leg.addChild(shin)
        
        let knee = SKPhysicsJointPin.joint(withBodyA: hip.physicsBody!,
                                           bodyB:  shin.physicsBody!,
                                           anchor: CGPoint(x: shin.position.x, y: shin.position.y + 140))
        
        self.physicsWorld.add(knee)
        
        foot = SKSpriteNode(imageNamed: "shoesR")
        foot.name = "foot"
        foot.position = CGPoint(x: shin.position.x + 50,
                                y: shin.position.y - shin.size.height / 2 + 40)
        foot.zPosition = 2
        foot.zRotation = -0.45

        foot.physicsBody = SKPhysicsBody(texture: foot.texture!,
                                            size: foot.size)

        foot.physicsBody?.allowsRotation = false
        foot.physicsBody?.affectedByGravity = false
        foot.physicsBody?.linearDamping = 10
        foot.physicsBody?.categoryBitMask = PhysicsCategory.Leg
        foot.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        foot.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        leg.addChild(foot)
        
        let ankle = SKPhysicsJointPin.joint(withBodyA: shin.physicsBody!,
                                            bodyB: foot.physicsBody!,
                                            anchor: foot.position)
        self.physicsWorld.add(ankle)
        
        hip.zRotation = 2
    }
    
    func createBall(atPoint pos : CGPoint) {
        let ball = SKSpriteNode(imageNamed: "ball1")
        ball.position = pos
        ball.setScale((self.size.width / 8) / ball.size.width)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 1.1
        ball.physicsBody?.linearDamping = 0.3
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Leg | PhysicsCategory.Body
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Leg | PhysicsCategory.Body
        self.addChild(ball)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        let t = touches.first!.location(in: self)
        targetPos = CGPoint(x: max(self.minX!, t.x - 100), y: min(self.maxY!, t.y + 150))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let t = touches.first!.location(in: self)
        targetPos = CGPoint(x: max(self.minX!, t.x - 100), y: min(self.maxY!, t.y + 150))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        targetPos = self.defautTargetPos
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let leg = self.childNode(withName: "leg")!
//        print(leg.position)
        let foot = leg.childNode(withName: "foot")
        foot?.zRotation = pow(3 * (foot?.position.x)! / self.size.width, 3) + 0.3
        foot?.physicsBody?.applyForce(CGVector(dx: 100 * (targetPos!.x - (foot?.position.x)!),
                                               dy: 100 * (targetPos!.y - (foot?.position.y)!)))
//        foot?.physicsBody?.applyForce(CGVector(dx: 10000, dy: 0))
        
        
        let hip  = leg.childNode(withName: "hip")
        let shin = leg.childNode(withName: "shin")
        
        
        
//        print(hip.zRotation, shin.zRotation)
        if ((hip?.zRotation)! < (shin?.zRotation)! + 0.2 )  {
            shin?.physicsBody?.applyAngularImpulse(10 * ((hip?.zRotation)! - (shin?.zRotation)! - 0.2))
        }
        
        self.leg?.zRotation += 0.1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let timeDiff = Double(Date().timeIntervalSince1970 - lastContactTime.timeIntervalSince1970)
        if (timeDiff < MinTimeContactInterval) {
            return
        }
        scoreValue += 1
//        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
//        print("Collision = \(collision)")
    }
    
}
