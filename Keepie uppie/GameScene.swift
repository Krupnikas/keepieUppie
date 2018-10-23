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
    
    private var leg : SKSpriteNode?
    
    var background = SKSpriteNode(imageNamed: "background.jpg")
    
    override func didMove(to view: SKView) {
        
        background.setScale(self.size.height / background.size.height)
        background.zPosition = -1
        self.addChild(background)
    
        createLeg()
        createBall(atPoint: CGPoint(x:  self.size.width / 8 ,
                                    y:  self.size.width / 3 ))
        
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.view?.showsPhysics = true
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
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
        hip.position = CGPoint(x: -w / 4, y: 0)
        hip.name = "hip"
        hip.physicsBody = SKPhysicsBody(texture: hip.texture!, size: hip.size)
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
        self.addChild(ball)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        for t in touches {
            let leg = self.childNode(withName: "leg")
            let foot = leg?.childNode(withName: "foot")
            self.leg?.childNode(withName: "foot")?.physicsBody?.applyForce(CGVector(dx: 100 * (t.location(in: self).x - (foot?.position.x)!),
                                                  dy: 100 * (t.location(in: self).y - (foot?.position.y)!)))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let leg = self.childNode(withName: "leg")
            let foot = leg?.childNode(withName: "foot")
            foot?.physicsBody?.applyForce(CGVector(dx: 100 * (t.location(in: self).x - (foot?.position.x)!),
                                                   dy: 100 * (t.location(in: self).y - (foot?.position.y)!)))
            print("Force applied")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let leg = self.childNode(withName: "leg")!
//        print(leg.position)
        let foot = leg.childNode(withName: "foot")
        foot?.zRotation = (foot?.position.x)! / self.size.width + 0.2
//        foot?.physicsBody?.applyForce(CGVector(dx: 10000, dy: 0))
        
        
        let hip  = leg.childNode(withName: "hip")
        let shin = leg.childNode(withName: "shin")
        
//        print(hip.zRotation, shin.zRotation)
        if ((hip?.zRotation)! < (shin?.zRotation)! )  {
            shin?.physicsBody?.applyAngularImpulse(10 * ((hip?.zRotation)! - (shin?.zRotation)!))
        }
        
        self.leg?.zRotation += 0.1
    }
}
