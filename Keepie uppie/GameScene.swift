//
//  GameScene.swift
//  Keepie uppie
//
//  Created by Сергей Крупник on 29.08.2018.
//  Copyright © 2018 Сергей Крупник. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var foot : SKSpriteNode?
    
    var background = SKSpriteNode(imageNamed: "background.jpg")
    
    override func didMove(to view: SKView) {
        
        background.setScale(self.size.height / background.size.height)
        background.zPosition = -1
        self.addChild(background)
    
        createLeg()
        createBall(atPoint: CGPoint(x: -self.size.width / 8 ,
                                    y:  self.size.width / 3 ))
        
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }
    
    func createLeg() {
        let w = self.size.width
        
//        let hip  = SKShapeNode.init(rectOf: CGSize.init(width: w / 10, height: w), cornerRadius: w * 0.3)
//        hip.position = CGPoint(x: w / 3, y: w)
//        hip.fillColor = SKColor.orange
//        self.addChild(hip)
//
//        let shin = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//        shin.fillColor = SKColor.orange
//        self.addChild(shin)
        
        self.foot = SKSpriteNode(imageNamed: "shoes")
        self.foot?.name = "foot"
        self.foot?.physicsBody = SKPhysicsBody(texture: (self.foot?.texture)!,
                                               size: (self.foot?.size)!)
        self.foot?.position = CGPoint(x: -w / 8, y: -w / 2)
        self.foot?.zRotation = -0.45
        self.foot?.physicsBody?.allowsRotation = false
        self.foot?.physicsBody?.affectedByGravity = false
        self.foot?.physicsBody?.linearDamping = 10
        self.addChild(self.foot!)
    }
    
    func createBall(atPoint pos : CGPoint) {
        let ball = SKSpriteNode(imageNamed: "ball1")
        ball.position = pos
        ball.setScale((self.size.width / 8) / ball.size.width)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 0.9
        ball.physicsBody?.linearDamping = 0.5
        self.addChild(ball)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
            self.foot?.physicsBody?.applyForce(CGVector(dx: 100 * (t.location(in: self).x - (foot?.position.x)!),
                                                        dy: 100 * (t.location(in: self).y - (foot?.position.y)!)))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchMoved(toPoint: t.location(in: self))
            self.foot?.physicsBody?.applyForce(CGVector(dx: 100 * (t.location(in: self).x - (foot?.position.x)!),
                                                        dy: 100 * (t.location(in: self).y - (foot?.position.y)!)))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        self.foot?.zRotation = (self.foot?.position.x)! / self.size.width - 0.2
    }
}
