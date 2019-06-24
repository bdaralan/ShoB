//
//  CoreDataStack.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
// reference: https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes

import CoreData


typealias UbiquityIdentityToken = (NSCoding & NSCopying & NSObjectProtocol)


class CoreDataStack: NSObject {
    
    static private(set) var current = CoreDataStack(userIdentityToken: FileManager.default.ubiquityIdentityToken)
    
    
    let persistentContainer: NSPersistentContainer
    
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    
    private init(userIdentityToken: UbiquityIdentityToken?) {
        // use CloudKit container
        persistentContainer = NSPersistentCloudKitContainer(name: "ShoB")
        
        // locate user store location using user token
        let userIdentityTokenUUID = CoreDataStack.getUserIdentityTokenUUID(for: userIdentityToken)
        let storeDefaultUrl = NSPersistentContainer.defaultDirectoryURL()
        let storeUrl = storeDefaultUrl.appendingPathComponent("\(userIdentityTokenUUID)/database.store")
        
        // create store description
        let storeDescription = NSPersistentStoreDescription(url: storeUrl)
        
        // initialize the CloudKit schema
        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.bdaralan.ShoB")
        options.shouldInitializeSchema = true // toggle to false when go in production
        storeDescription.cloudKitContainerOptions = options
        
        // assign store description
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        // auto merge new changes when store gets new updates
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        // load container
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error { fatalError("could not load persistent store with error: \(error)") }
        }
        
        super.init()
        
        // keep track of last user
        StandardUserDefaults.lastUserIdentityToken = userIdentityTokenUUID
        
        // listen to user identity token changed notitfication
        NotificationCenter.default.addObserver(self, selector: #selector(userIdentifyChanged(_:)), name: .NSUbiquityIdentityDidChange, object: nil)
    }
    
    @objc func userIdentifyChanged(_ notification: Notification) {
        let newToken = FileManager.default.ubiquityIdentityToken
        
        let lastTokenUUID = StandardUserDefaults.lastUserIdentityToken
        let newTokenUUID = CoreDataStack.getUserIdentityTokenUUID(for: newToken)
        
        guard lastTokenUUID != newTokenUUID else { return }
        CoreDataStack.current = CoreDataStack(userIdentityToken: newToken)
        StandardUserDefaults.lastUserIdentityToken = newTokenUUID
    }
}


// MARK: - User Account Token for Local Use


extension CoreDataStack {
    
    static func getUserIdentityTokenUUID(for token: UbiquityIdentityToken?) -> String {
        guard let token = token else {
            return StandardUserDefaults.unknownUserIdentityToken
        }
        
        // find uuid from the dictionary
        var tokenDict = StandardUserDefaults.userIdentityTokenDictionary
        for (tokenUUID, ubiquityToken) in tokenDict where ubiquityToken.isEqual(token) {
            return tokenUUID
        }
        
        // if does not exist, create one and store it
        let newTokenUUID = UUID().uuidString
        tokenDict[newTokenUUID] = token
        StandardUserDefaults.userIdentityTokenDictionary = tokenDict
        
        return newTokenUUID
    }
}

