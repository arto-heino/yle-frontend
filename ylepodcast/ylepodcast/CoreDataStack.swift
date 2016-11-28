//
//  CoreDataStack.swift
//  ylepodcast
//
//  Created by Arto Heino on 28/11/16.
//  Copyright © 2016 Metropolia. All rights reserved.
//
import UIKit
import CoreData

class CoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ylepodcast")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error), \(error)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
