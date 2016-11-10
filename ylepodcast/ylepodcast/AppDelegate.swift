//
//  AppDelegate.swift
//  ylepodcast
//
//  Created by Arto Heino on 28/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var history = [Podcast]()
    
    
    
    
    //DUMMYDATA FOR TESTING
    
    static var dummyData = [Podcast]()
    
    static func loadSamplePods() {
        
        let photo1 = UIImage(named: "defaultImage")!
        
        let podcast1 = Podcast(collection: "Avara luonto", photo: photo1, description: "Tropiikin linnut pesäpuuhissa. ", duration: "10.15", tags: ["luonto", "linnut", "kasvit"])!
        
        let podcast2 = Podcast(collection: "Amerikan historia", photo: photo1, description: "Intiaanit.", duration: "20.00", tags: ["amerikka", "historia", "intiaani"])!
        
        let podcast3 = Podcast(collection: "Aamulypsyn parhaat", photo: photo1, description: "Jaajo ja perälä perseilee.", duration: "00.33", tags: ["jaajo", "lypsy", "perälä"])!
        
        
        AppDelegate.dummyData += [podcast1, podcast2, podcast3]
        
    }



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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


}

