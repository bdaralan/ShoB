//
//  CoreDataStack.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
// reference: https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes

import CoreData


/// The core data stack that manages user's object graph.
class CoreDataStack: NSObject {
    
    static private(set) var current = CoreDataStack()
    
    
    let persistentContainer: NSPersistentContainer
    
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    
    private override init() {
        // use CloudKit container
        persistentContainer = NSPersistentCloudKitContainer(name: "ShoB")
        
        // auto merge new changes when store gets new updates
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        // load container
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error { fatalError("could not load persistent store with error: \(error)") }
        }
        
        super.init()
        
        AppCache.ubiquityIdentityToken = FileManager.default.ubiquityIdentityToken
        setupUserIdentityChangeNotification()
    }
}


// MARK: - Handle Identity Changed

extension CoreDataStack {
    
    static let nCoreDataStackDidChange = Notification.Name("CoreDataStack.nCoreDataStackDidChange")
    
    
    func setupUserIdentityChangeNotification() {
        let notificationCenter = NotificationCenter.default
        let notification = Notification.Name.NSUbiquityIdentityDidChange
        let handler = #selector(userIdentifyChanged(_:))
        notificationCenter.addObserver(self, selector: handler, name: notification, object: nil)
    }
    
    @objc func userIdentifyChanged(_ notification: Notification) {
        let cachedToken = AppCache.ubiquityIdentityToken
        let currentToken = FileManager.default.ubiquityIdentityToken
        
        AppCache.ubiquityIdentityToken = currentToken // update cache
        
        switch (cachedToken == nil, currentToken == nil) {
            
        case (false, true), (true, false):
            reloadCoreDataStore()
            
        case (false, false) where !cachedToken!.isEqual(currentToken!):
            reloadCoreDataStore()
            
        default: break
        }
    }
    
    func reloadCoreDataStore() {
        CoreDataStack.current = CoreDataStack()
        NotificationCenter.default.post(name: CoreDataStack.nCoreDataStackDidChange, object: nil)
    }
}
