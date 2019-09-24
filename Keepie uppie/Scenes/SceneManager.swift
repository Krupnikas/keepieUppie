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

protocol RewardedAdScene {
    func rewardedAdStarted()
    func rewardedAdWatchedEnough()
    func rewardedAdClosed()
}

protocol InterstitialAdScene {
    func interstitialAdWatched()
    func interstitialAdWillPresent()
    func interstitialAdWillDismissScreen()
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
    var rewardedAdScenes = [RewardedAdScene]()
    var interstitialAdScenes = [InterstitialAdScene]()
    
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
        rewardedAdScenes.removeAll()
        interstitialAdScenes.removeAll()
        
        let mainMenu = MainMenuScene(fileNamed: "MainMenuScene.sks")!
        mainMenu.scaleMode = .aspectFill
        SceneManager.setup.view.presentScene(mainMenu)
    }
    
    func presentGameScene() {
        let game = GameScene(fileNamed: "GameScene.sks")!
        game.scaleMode = .aspectFill
        
        rewardedAdScenes.append(game)
        interstitialAdScenes.append(game)
        
        SceneManager.setup.view.presentScene(game)
    }
    
    func presentWorkshopScene() {
        rewardedAdScenes.removeAll()
        interstitialAdScenes.removeAll()
        
        let workshop = WorkshopScene(size: GameSize)
        workshop.scaleMode = .aspectFill
        SceneManager.setup.view.presentScene(workshop)
    }
    
    func notifyRewardedAdStarted() {
        for adScene in rewardedAdScenes {
            adScene.rewardedAdStarted()
        }
    }
    
    func notifyRewardedAdWatchedEnough() {
        for adScene in rewardedAdScenes {
            adScene.rewardedAdWatchedEnough()
        }
    }
    
    func notifyRewardedAdClosed() {
        for adScene in rewardedAdScenes {
            adScene.rewardedAdClosed()
        }
    }
    
    func notifyInterstitialAdWatched() {
        for adScene in interstitialAdScenes {
            adScene.interstitialAdWatched()
        }
    }
    
    func notifyInterstitialAdWillPresent() {
        for adScene in interstitialAdScenes {
            adScene.interstitialAdWillPresent()
        }
    }
    
    func notifyInterstitialAdWillDismissScreen() {
        for adScene in interstitialAdScenes {
            adScene.interstitialAdWillDismissScreen()
        }
    }
}
 
