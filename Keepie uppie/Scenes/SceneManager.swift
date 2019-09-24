//
//  SceneLogic.swift
//  EventHorizon
//
//  Created by deserg on 17.09.17.
//  Copyright © 2017 deserg. All rights reserved.
//

import Foundation
import SpriteKit
import GoogleMobileAds
// singleton to navigate between scenes

class SceneManagerSetupHelper {
    var view: SKView!
}

struct SceneType {
    static let None = 0
    static let MainMenu = 1
    static let Game = 2
}

protocol AdScene {
    func adStarted()
    func adWatchedEnough()
    func adClosed()
    
    func interstitialAdWatched()
}

class SceneManager {

    
    static let instance = SceneManager()
    private static let setup = SceneManagerSetupHelper()
    
    class func setup(view: SKView) {
        SceneManager.setup.view = view
        
    }
    
    //    var mainMenu: MainMenuScene
    //    var game: GameScene
    //    var workshop: WorkshopScene
    var adScenes = [AdScene]()
    
    var score: Int {
        didSet {
            setUserScoreFromDevice(score: score)
        }
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
        adScenes.removeAll()
        let mainMenu = MainMenuScene(fileNamed: "MainMenuScene.sks")!
        mainMenu.scaleMode = .aspectFill
        SceneManager.setup.view.presentScene(mainMenu)
    }
    
    func presentGameScene() {
        let game = GameScene(fileNamed: "GameScene.sks")!
        game.scaleMode = .aspectFill
        adScenes.append(game)
        SceneManager.setup.view.presentScene(game)
    }
    
    func presentWorkshopScene() {
        adScenes.removeAll()
        let workshop = WorkshopScene(size: GameSize)
        workshop.scaleMode = .aspectFill
        SceneManager.setup.view.presentScene(workshop)
    }
    
    func notifyAdStarted() {
        for adScene in adScenes {
            adScene.adStarted()
        }
    }
    
    func notifyAdWatchedEnough() {
        for adScene in adScenes {
            adScene.adWatchedEnough()
        }
    }
    
    func notifyAdClosed() {
        for adScene in adScenes {
            adScene.adClosed()
        }
    }
    
    func notifyInterstitialAdWatched() {
        for adScene in adScenes {
            adScene.interstitialAdWatched()
        }
    }
}
 
