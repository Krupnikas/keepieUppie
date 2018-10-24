//
//  SceneLogic.swift
//  EventHorizon
//
//  Created by deserg on 17.09.17.
//  Copyright © 2017 deserg. All rights reserved.
//

import Foundation
import SpriteKit
// singleton to navigate between scenes

class SceneManagerSetupHelper {
    var view: SKView!
}

class SceneManager {
    
    static let instance = SceneManager()
    private static let setup = SceneManagerSetupHelper()
    
    class func setup(view: SKView) {
        SceneManager.setup.view = view
        
    }
    
    private init() {
        let view = SceneManager.setup.view
        guard view != nil else {
            fatalError("SceneManager: init: setup has not been called")
        }
        
        if let scoreLoaded = getUserScoreFromDevice() {
            score = scoreLoaded
        } else {
            score = ScoreDefault
        }
        
//        mainMenu = MainMenuScene(fileNamed: "MainMenuScene.sks")!
//        mainMenu.scaleMode = .aspectFill
        
//        game = GameScene(fileNamed: "GameScene.sks")!
//        game.scaleMode = .aspectFill
        
//        workshop = WorkshopScene(size: GameSize)
//        workshop.scaleMode = .aspectFill
    }
    
    func presentMainMenuScene() {
        let mainMenu = MainMenuScene(fileNamed: "MainMenuScene.sks")!
        mainMenu.scaleMode = .aspectFill
        SceneManager.setup.view.presentScene(mainMenu)
    }
    
    func presentGameScene() {
        let game = GameScene(fileNamed: "GameScene.sks")!
        game.scaleMode = .aspectFill
        SceneManager.setup.view.presentScene(game)
    }
    
    func presentWorkshopScene() {
        let workshop = WorkshopScene(size: GameSize)
        workshop.scaleMode = .aspectFill
        SceneManager.setup.view.presentScene(workshop)
    }
    
//    var mainMenu: MainMenuScene
//    var game: GameScene
//    var workshop: WorkshopScene
    
    var score: Int {
        didSet {
            setUserScoreFromDevice(score: score)
        }
    }
}
 
