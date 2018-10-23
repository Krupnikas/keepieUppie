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
    
    let buttonSize: CGSize
    var buttonStart: SKNode!
    var buttonShop: SKNode!
    var buttonAbout: SKNode!
    
    override init(size: CGSize) {
        
        buttonSize = CGSize(width: GameSize.width * CGFloat(PercentageButtonWidth),
                            height: GameSize.height * CGFloat(PercentageButtonHeight))
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        createButtons()
        
    }
    
    func createButtons()
    {
        buttonStart = SKSpriteNode(imageNamed: "button_start")
        buttonStart.position = CGPoint(x: self.frame.midX, y: self.frame.midY);
        
        print(buttonSize)
        
        buttonShop = SKSpriteNode(imageNamed: "button_shop")
        buttonShop.position = CGPoint(x: self.frame.midX, y: self.frame.midY - buttonStart.frame.height);
        
        buttonAbout = SKSpriteNode(imageNamed: "button_about")
        buttonAbout.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 2 * buttonStart.frame.height);
        
        self.addChild(buttonStart)
        self.addChild(buttonShop)
        self.addChild(buttonAbout)
    }
    
    func onStartClicked() {
        view!.presentScene(SceneManager.instance.game)
    }
    
    func onShopClicked() {
        view!.presentScene(SceneManager.instance.workshop)
    }
    
    func onAboutClicked() {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        // Check if the location of the touch is within the button's bounds
        if buttonStart.contains(touchLocation) {
            onStartClicked()
        } else if buttonShop.contains(touchLocation) {
            onShopClicked()
        } else if buttonAbout.contains(touchLocation) {
            onAboutClicked()
        }
    }
    
}
