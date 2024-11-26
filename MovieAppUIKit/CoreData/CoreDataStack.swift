//
//  CoreDataStack.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/21/24.
//

import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    private init(isTest: Bool = false) {
        self.persistentContainer = NSPersistentContainer(name: "FavoritesData")
        
        if isTest {
            let description = NSPersistentStoreDescription()
                description.type = NSInMemoryStoreType
                persistentContainer.persistentStoreDescriptions = [description]
            }
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                #if DEBUG
                fatalError("Failed to load persistent stores: \(error)")
                #else
                print("Failed to load persistent stores: \(error)")
                // Optionally log to a monitoring service
                #endif
            }
            print("loaded persistent stores successfully")
         
        }
        
        self.mainContext = persistentContainer.viewContext
        self.mainContext.automaticallyMergesChangesFromParent = true
        
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.backgroundContext.parent = mainContext
        
    }
    
    static func testInstance() -> CoreDataStack {
        return CoreDataStack(isTest: true)
    }
}
