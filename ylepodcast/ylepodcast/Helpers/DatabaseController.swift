//
//  DatabaseController.swift
//  ylepodcast
//
//  Created by Arto Heino on 28/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//

import Foundation
import CoreData

class DatabaseController{
    
    private init(){
        
    }
    
    class func getContext() -> NSManagedObjectContext {
        return DatabaseController.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Delete support
    class func clear(table tableName : String) {
        
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        let persistentStoreCoordinator = context.persistentStoreCoordinator!
        
        do {
            try persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    // MARK: - Core Data Saving support
    class func saveContext () {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
