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
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var splashScreenShown = false
    
    var podcastUrl: String?
    var podcastName: String?
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var audioController: AudioController?
    
    lazy var coreDataStack = CoreDataStack()
    
    static func addPodcastToCoreData(podcast: Podcast) {
        //let entity = NSEntityDescription.insertNewObject(forEntityName: "Podcast", into: moc) as! Podcast
        let core = CoreDataStack.init()
        let entity = Podcast(context: context)
        entity.name = podcast.podcastCollection
        
        //entity.setValue(podcast.podcastCollection, forKey: "podcastCollection")
        //entity.setValue(podcast.podcastDescription, forKey: "podcastDescription")
        //entity.setValue(podcast.podcastTags, forKey: "podcastTags")
        //entity.setValue(podcast.podcastCollectionID, forKey: "podcastCollectionID")
        //entity.setValue(podcast.podcastDuration, forKey: "podcastDuration")
        //entity.setValue(podcast.podcastID, forKey: "podcastID")
        //entity.setValue(podcast.podcastImageURL, forKey: "podcastImageURL")
        //entity.setValue(podcast.podcastURL, forKey: "podcastURL")
        //entity.setValue(podcast.podcastTitle, forKey: "podcastTitle")
        
        core.saveContext()

    }
    //fetches data from Core
    /*static func fetchPodcastsFromCoreData() -> [Podcast] {
        // Return cached value if available
        if podcastsFromCoreData.count > 0 {
            return podcastsFromCoreData
        // Otherwise read through CoreData
        } else {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Podcast")
                let fetchResults = try moc.fetch(fetchRequest) as! [Podcast]
                
                podcastsFromCoreData = fetchResults
                return podcastsFromCoreData
            } catch {
                fatalError("Failed to fetch podcasts from CoreData")
            }
        }
    }
 */
    
    //shows splashscreen
    
    let commandCenter = MPRemoteCommandCenter.shared()

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
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
    
    func setupPlayer(aController: AudioController, pUrl: String, pName: String) {
        podcastUrl = pUrl
        podcastName = pName
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
    }
    
    func pause() {
        audioController?.pause()
        player?.pause()
        updateInfoCenter()
        //MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : podcastName!, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 0), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.asset.duration)!), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player!.currentTime())]
    }
    
    func updateInfoCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : podcastName!, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 1), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.asset.duration)!), MPNowPlayingInfoPropertyElapsedPlaybackTime : CMTimeGetSeconds(player!.currentTime())]
    }
}

