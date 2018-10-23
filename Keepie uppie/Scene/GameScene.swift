//
//  GameScene.swift
//  EventHorizon
//
//  Created by deserg on 17.09.17.
//  Copyright © 2017 deserg. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    // constants
    let shipSpeed: CGFloat = 500
    let starSize: CGFloat = 20
    let asteroidSize: CGFloat = 350
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    var playableRect: CGRect
//    var eventHorizon: EventHorizonHelper
    
    let SpacecraftMoveRectPercentage: CGFloat = 0.2
    let SpacecraftShootRectPercentage: CGFloat = 0.75
    let TopMenuRectPercentage: CGFloat = 0.05
    
    var spacecraftMoveRect: CGRect
    var spacecraftShootRect: CGRect
    var topMenuRect: CGRect
    
    
    // helping classes
    var motionManager = CMMotionManager()
    
    
    // game data
    var spacecraft: Ship
    
    var stars: Array<Star> = []
    var enemies: Array<SKSpriteNode> = []
    
    
    func spawnStar(coef: CGFloat = 1, inOrigin: Bool = true) {
        stars.append(Star(imagedNamed: "star", parent: self, coef: coef, inOrigin: inOrigin))
    }
    
    func spawnAsteroid(coef: CGFloat = 1, inOrigin: Bool = true) {
        
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.name = "asteroid"
        asteroid.size = CGSize(width: asteroidSize * coef, height: asteroidSize * coef)
        asteroid.zRotation = CGFloat.random(min: 0, max: CGFloat(Double.pi))
        asteroid.zPosition = 45
        if inOrigin {
            asteroid.position.y = playableRect.height + asteroid.size.height / 2
            let asteroidMinX = playableRect.minX - asteroid.size.width / 2
            let asteroidMaxX = playableRect.maxX + asteroid.size.width / 2
            asteroid.position.x = CGFloat.random(min: asteroidMinX, max: asteroidMaxX)
        } else {
            asteroid.position = EventHorizon.instance.helper.randomPoint()
        }
        let asteroidScale = EventHorizon.instance.helper.scaleFor(yCoord: asteroid.position.y)
        asteroid.setScale(asteroidScale)
        asteroid.run(SKAction.repeatForever( SKAction.rotate(byAngle: CGFloat.random(min: -0.1, max: 0.1), duration: 0.1) ))
        
        addChild(asteroid)
        EventHorizon.instance.addObject(asteroid)
    }
    
    func updateDt(_ currentTime: TimeInterval) {
        if (lastUpdateTime == 0) {
            lastUpdateTime = currentTime
        }
        
        dt = currentTime - self.lastUpdateTime
        lastUpdateTime = currentTime
    }
    
    override init(size: CGSize) {
        
//        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableWidth = size.width// size.height / maxAspectRatio // 2
        let playableMargin = CGFloat(0) //(size.width-playableWidth)/2.0 // 3
        
//        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
//        let playableHeight = size.width / maxAspectRatio // 2
//        let playableMargin = (size.height-playableHeight)/2.0 // 3
//
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: playableWidth,
                              height: size.height)
        
        EventHorizon.setup(playableRect: playableRect, speed: shipSpeed, distanceCoeff: 1, scaleCoeff: 50)
        
        spacecraftMoveRect = CGRect(x: 0, y: playableMargin,
                                    width: playableWidth,
                                    height: size.height * SpacecraftMoveRectPercentage)
        
        spacecraftShootRect = CGRect(x: playableMargin, y: spacecraftMoveRect.height,
                                    width: playableWidth,
                                    height: size.height * SpacecraftShootRectPercentage)
        
        topMenuRect = CGRect(x: playableMargin, y: spacecraftMoveRect.height + spacecraftShootRect.height,
                                     width: playableWidth,
                                     height: size.height * TopMenuRectPercentage)
        
//        print(playableRect.origin)
//        print(playableRect.size)
        
//        eventHorizon = EventHorizonHelper(screenRect: playableRect, distanceCoeff: 1, scaleCoeff: 50)
        
        let shipDirector = ShipDirector()
        spacecraft = shipDirector.construct(builder: FastShipBuilder())

        spacecraft.position.x = playableRect.minX + playableRect.size.width / 2
        spacecraft.position.y = playableRect.minY + spacecraft.size.height / 2
        
        spacecraft.zPosition = 50
        spacecraft.name = "spacecraft"
        spacecraft.constraints = [ SKConstraint.positionY(SKRange.init(lowerLimit: playableRect.minX, upperLimit: playableRect.maxX)) ]
        
//        destY = spacecraft.position.y
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint(x: 0, y: 0)
        
        backgroundColor = SKColor(red: 0, green: 0, blue: 0.05, alpha: 1)
        let vinetkaNode = SKSpriteNode(imageNamed: "vinetka")
        vinetkaNode.size = size
        vinetkaNode.anchorPoint = CGPoint(x: 0, y: 0)
        vinetkaNode.position = CGPoint(x: 0, y: 0)
        vinetkaNode.name = "vinetka"
        vinetkaNode.zPosition = 100
        addChild(vinetkaNode)
        
        addChild(spacecraft)
        
        for _ in (0...200) {
            spawnStar(inOrigin: false)
        }
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnStar()
        }, SKAction.wait(forDuration: 0.1)])))

        run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnAsteroid()
            }, SKAction.wait(forDuration: 4)])))
        
//        if motionManager.isAccelerometerAvailable == true {
//            print("AVAILIABALE!")
//            // 2
//            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
//                data, error in
//
//                let currentY = self.spacecraft.position.y
//
//                guard let d = data else {
//                    return
//                }
//
//                // 3
////                print()
////                print("x: \(d.acceleration.x)")
////                print("y: \(d.acceleration.y)")
////                print("z: \(d.acceleration.z)")
//                let accVal = d.acceleration.x
//                let coef: Double = 3000
//                let border = 0.0
//                self.destY = currentY - CGFloat((accVal - border) * coef)
//            })

//        }
    }
    
    override func sceneDidLoad() {
        
    }
    
    // touching logics
    func spacecraftMoveRectTouched(touchLocation: CGPoint) {
        spacecraft.setDestination(destination: touchLocation)
    }
    
    func spacecraftShootRectTouched(touchLocation: CGPoint) {
        spacecraft.shoot(to: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        var touchLocations: [CGPoint] = []
        
        for touch in touches {
            let touchLocation = touch.location(in: self)
            touchLocations.append(touchLocation)
        }
        
        touchLocations = touchLocations.sorted(by: { $0.y < $1.y })
        
        if touchLocations.count == 1 {
            let location = touchLocations[0]
            if spacecraftMoveRect.contains(location) {
                spacecraftMoveRectTouched(touchLocation: location)
            } else if spacecraftShootRect.contains(location) {
                spacecraftShootRectTouched(touchLocation: location)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        touchesBegan(touches, with: event)
    }
    
    func checkBordersSpacecraft() {
        
        let pos = spacecraft.position
        print("Pos: \(pos)")
        
        if pos.x < playableRect.minX {
            spacecraft.position.x = playableRect.minX
        } else if pos.x > playableRect.maxX {
            spacecraft.position.x = playableRect.maxX
        }
        
        let minY = playableRect.minY
        let maxY = playableRect.maxY
        print("Min Y: \(minY)")
        print("Max Y: \(maxY)")
        if pos.y < minY {
            spacecraft.position.y = minY
        } else if pos.y > maxY {
            spacecraft.position.y = maxY
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateDt(currentTime)
        
        EventHorizon.instance.update(dt: dt)
//        for node in children {
//            if node.name == "spacecraft" || node.name == "vinetka" {
//                continue
//            }
//
//            guard let node = node as? SKSpriteNode else {
//                return
//            }
//
//            if node.position.y + node.size.height < self.playableRect.minY {
//                node.removeFromParent()
//            }
//            node.position.y = self.eventHorizon.nextYCoordFor(yCoord: node.position.y, speed: self.shipSpeed, dt: self.dt)
//            let scale = self.eventHorizon.scaleFor(yCoord: node.position.y)
//            node.xScale = scale// * self.eventHorizon.xScaleFor(xCoord: node.position.x)
//            node.yScale = scale
//           // node.zRotation += CGFloat.random(min: -0.1, max: 0.1)
//        }
        
        spacecraft.onFly(dt)
        

    }
}
