//
//  GameViewController.swift
//  Keepie uppie
//
//  Created by Сергей Крупник on 29.08.2018.
//  Copyright © 2018 Сергей Крупник. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

let testAdUnitId = "ca-app-pub-3940256099942544/1712485313"
let prodAdUnitId = "ca-app-pub-4718486799866350/3586090329"

class GameViewController: UIViewController, GADRewardBasedVideoAdDelegate {

    private var rewardBasedVideo: GADRewardBasedVideoAd!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self
//        #if DEBUG
//        let request = GADRequest()
//        request.testDevices = [ "fc7552e962ddcbe16ff92cfaadfb1fa5" ] // Sample device ID
//        rewardBasedVideo.load(request, withAdUnitID: testAdUnitId)
//        #else
        let request = GADRequest()
        rewardBasedVideo.load(request, withAdUnitID: prodAdUnitId)
//        #endif
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            
            SceneManager.setup(view: view)
            
//            view.showsFPS = true
//            view.showsNodeCount = true
            view.ignoresSiblingOrder = true
            
            SceneManager.instance.presentMainMenuScene()
            
            super.viewDidLoad()
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // reward video methods
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        
        SceneManager.instance.notifyAdWatchedEnough()
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
        SceneManager.instance.notifyAdStarted()
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad has completed.")
        
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        SceneManager.instance.notifyAdClosed()
        #if DEBUG
        let request = GADRequest()
        request.testDevices = [ "fc7552e962ddcbe16ff92cfaadfb1fa5" ] // Sample device ID
        rewardBasedVideo.load(request, withAdUnitID: testAdUnitId)
        #else
        rewardBasedVideo.load(GADRequest(), withAdUnitID: prodAdUnitId)
        #endif
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load: " + error.localizedDescription)
    }
}
