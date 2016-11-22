//
//  AppDelegate.swift
//  ylepodcast
//
//  Created by Arto Heino on 28/10/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var splashScreenShown = false
    
    
    //Add to COredata
    static let moc = DataController().managedObjectContext
    static private var podcastsFromCoreData = [Podcast]()
    
    static func addPodcastToCoreData(podcast: Podcast) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Podcast", into: moc) as! Podcast
        
        entity.setValue(podcast.podcastCollection, forKey: "podcastCollection")
        entity.setValue(podcast.podcastDescription, forKey: "podcastDescription")
        entity.setValue(podcast.podcastTags, forKey: "podcastTags")
        entity.setValue(podcast.podcastCollectionID, forKey: "podcastCollectionID")
        entity.setValue(podcast.podcastDuration, forKey: "podcastDuration")
        entity.setValue(podcast.podcastID, forKey: "podcastID")
        entity.setValue(podcast.podcastImageURL, forKey: "podcastImageURL")
        entity.setValue(podcast.podcastURL, forKey: "podcastURL")
        entity.setValue(podcast.podcastTitle, forKey: "podcastTitle")
        
        do {
            try moc.save()
        } catch {
            fatalError("Adding podcast failed")
        }
    }
    //fetches data from Core
    static func fetchPodcastsFromCoreData() -> [Podcast] {
        // Return cached value if available
        if podcastsFromCoreData.count > 0 {
            return podcastsFromCoreData
        // Otherwise read through CoreData
        } else {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Podcast")
                let fetchResults = try moc.fetch(fetchRequest) as! [Podcast]
                
                // REMOVE: Print all podcasts for testing purposes
                for item in fetchResults {
                    print(item.podcastCollection!)
                }
                
                podcastsFromCoreData = fetchResults
                return podcastsFromCoreData
            } catch {
                fatalError("Failed to fetch podcasts from CoreData")
            }
        }
    }
    
    //shows splashscreen
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoredataToYle")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }



}

