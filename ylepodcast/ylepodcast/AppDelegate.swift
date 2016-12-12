//
//  AppDelegate.swift
//  ylepodcast
//
//  Created by Arto Heino on 28/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var splashScreenShown = false
    
    var podcastUrl: String?
    var podcastName: String?
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var audioController: AudioController?
    var preferences = UserDefaults.standard
    let userLoad = UserLoads()
    let podcasts = HttpRequesting()
    let userPost = HttpPosts()
    var timer = Timer()
    var timeLeft: Int = 10
    var podcastPlaying: Podcast?
    
    let commandCenter = MPRemoteCommandCenter.shared()

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let context = DatabaseController.getContext()
        
        do{
            let result = try context.fetch(Podcast.fetchRequest())
            let podcast = result as! [Podcast]
            
            if(podcast.count == 0){
                podcasts.httpGetPodCasts()
            }else{
                print("do nothing")
            }
        }catch{
            print("model is lost")
        }
        
        let token: String = preferences.object(forKey: "userKey") as? String ?? ""
        if(token != ""){
            //Should load all login required material
            userLoad.getPlaylists()
            userLoad.getHistory()
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var rootViewController: UIViewController?
        if !AppDelegate.splashScreenShown {
            AppDelegate.splashScreenShown = true
            rootViewController = storyboard.instantiateViewController(withIdentifier: "SplashScreen")
        } else {
            rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        }
        
        let navigationController = UINavigationController(rootViewController: rootViewController!)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        //STYLING
        
        
        let navigationBarStyle = UINavigationBar.appearance()
        navigationBarStyle.barTintColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
        navigationBarStyle.tintColor = UIColor.init(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        
        let tabBarStyle = UITabBar.appearance()
        tabBarStyle.tintColor = UIColor.init(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        tabBarStyle.barTintColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        

        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        UIApplication.shared.statusBarStyle = .lightContent

    
        return true
        

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Add timer to history, if podcast is played more than 10 seconds add to history
    func timerRunning(){
        timeLeft -= 1
        let token = preferences.object(forKey: "userKey") as? String ?? ""
        let user = preferences.object(forKey: "userID")
        let url: String = "http://media.mw.metropolia.fi/arsu/history"
        if(timeLeft == 0){
        
            let context = DatabaseController.getContext()
            let history = History(context: context)
            let parameters: Parameters = ["podcast_id": podcastPlaying!.podcastID]
            
            userPost.httpPostToBackend(url: url, token: token, parameters: parameters){success in
                history.addToPodcast(self.podcastPlaying!)
                history.historyID = success["id"] as! Int64
                history.historyUserID = user as! Int64
                    
                DatabaseController.saveContext()
                self.timer.invalidate()
            }
        }
    }
    
    func setupPlayer(aController: AudioController, pUrl: String, podcast: Podcast) {
        podcastPlaying = podcast
        podcastUrl = pUrl
        podcastName = podcast.podcastCollection
        let url = URL(string: podcastUrl!)
        playerItem = AVPlayerItem(url: url!)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.pause()
            player?.replaceCurrentItem(with: playerItem)
        }
        audioController = aController
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(play))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(pause))
    }
    
    func togglePlayPause() {
        if player?.rate == 0 {
            play()
        } else {
            pause()
        }
    }
    
    func play() {
        player?.play()
        audioController?.play()
        updateInfoCenter()
        
        // Add timer to history
        if((preferences.object(forKey: "userKey")) != nil){
        timeLeft = 10
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        }
    }
    
    func pause() {
        // Stop the timer
        timer.invalidate()
        
        audioController?.pause()
        player?.pause()
        updateInfoCenter()
        //MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : podcastName!, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 0), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.asset.duration)!), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player!.currentTime())]
    }
    
    func updateInfoCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : podcastName!, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 1), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.asset.duration)!), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player!.currentTime())]
    }
}

