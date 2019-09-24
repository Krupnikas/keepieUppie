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

//let prodAdUnitId = "ca-app-pub-4718486799866350/3586090329"
let prodAdUnitId = "ca-app-pub-3940256099942544/4411468910"  // TEST
let interstAdUnitId = "ca-app-pub-4718486799866350/1288932724"

class GameViewController: UIViewController, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate {

    private var rewardBasedVideo: GADRewardBasedVideoAd!
    private var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self

        let request = GADRequest()
        rewardBasedVideo.load(request, withAdUnitID: prodAdUnitId)
        
        interstitial = createAndLoadInterstitial()
        
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
    
    // interstitial methods
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: interstAdUnitId)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        SceneManager.instance.notifyInterstitialAdWillPresent()
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        SceneManager.instance.notifyInterstitialAdWillDismissScreen()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        SceneManager.instance.notifyInterstitialAdWatched()
    }
    
    override func viewWillLayoutSubviews() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAd), name: NSNotification.Name(rawValue: "showAd"), object: nil)
    }
    
    @objc func showAd() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        
    }
    
    // reward video methods
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        
        SceneManager.instance.notifyRewardedAdWatchedEnough()
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
        SceneManager.instance.notifyRewardedAdStarted()
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad has completed.")
        
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        SceneManager.instance.notifyRewardedAdClosed()
        rewardBasedVideo.load(GADRequest(), withAdUnitID: prodAdUnitId)
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load: " + error.localizedDescription)
    }
}
