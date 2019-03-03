//
//  MainMenu.swift
//  EventHorizon
//
//  Created by deserg on 17.09.17.
//  Copyright © 2017 deserg. All rights reserved.
//

import Foundation
import SpriteKit
import CoreGraphics

class MainMenuScene: SKScene {
    
    private var background: SKSpriteNode!
    private var buttonPlay: SKSpriteNode!
    private var labelScore: SKLabelNode!
    
    let mainThemePlaying = SKAction.repeatForever(SKAction.playSoundFileNamed("sounds/main_theme", waitForCompletion: true))

//    override init(size: CGSize) {
//
//
//        buttonSize = CGSize(width: GameSize.width * CGFloat(PercentageButtonWidth),
//                            height: GameSize.height * CGFloat(PercentageButtonHeight))
//
//        super.init(size: size)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func didMove(to view: SKView) {
        background = childNode(withName: "background") as? SKSpriteNode
        buttonPlay = childNode(withName: "//button_play") as? SKSpriteNode
        labelScore = childNode(withName: "//label_score") as? SKLabelNode
        labelScore.text = String(SceneManager.instance.score)
        self.run(mainThemePlaying)
    }

    func onPlayClicked() {
        self.removeAllActions()
        SceneManager.instance.presentGameScene()
    }
    
    func onShopClicked() {
        
    }
    
    func onAboutClicked() {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.isEmpty {
            return
        }
        let touch = touches.first!
        let touchLocation = touch.location(in: background)
        // Check if the location of the touch is within the button's bounds
        if buttonPlay.contains(touchLocation) {
            onPlayClicked()
        }
    }
    
}
