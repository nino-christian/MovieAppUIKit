//
//  CoreDataStack.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/21/24.
//

import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "FavoritesData")

        persistentContainer.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Failed to load persistent stores: \(error!)")
            }
            
            print("loaded persistent stores successfully")
        }
        
        self.mainContext = persistentContainer.viewContext
        
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.backgroundContext.parent = mainContext
        
    }
}
