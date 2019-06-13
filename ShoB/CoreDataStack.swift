//
//  CoreDataStack.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
// reference: https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes

import CoreData


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
        let storeUrl = storeDefaultUrl.appendingPathComponent("\(userIdentityTokenUUID).store")
        
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
        
        // save for later comparison
        UserDefaults.standard.setValue(userIdentityTokenUUID, forKey: CoreDataStack.kLastUserUbiquityIdetityTokenUUID)
        
        // listen to user identity token changed notitfication
        NotificationCenter.default.addObserver(self, selector: #selector(userIdentifyChanged(_:)), name: .NSUbiquityIdentityDidChange, object: nil)
    }
    
    @objc func userIdentifyChanged(_ notification: Notification) {
        let newUbiquityToken = FileManager.default.ubiquityIdentityToken
        
        let userDefaults = UserDefaults.standard
        let lastTokenUUID = userDefaults.string(forKey: CoreDataStack.kLastUserUbiquityIdetityTokenUUID)
        let newTokenUUID = CoreDataStack.getUserIdentityTokenUUID(for: newUbiquityToken)
        
        guard lastTokenUUID != newTokenUUID else { return }
        CoreDataStack.current = CoreDataStack(userIdentityToken: newUbiquityToken)
        userDefaults.setValue(newTokenUUID, forKey: CoreDataStack.kLastUserUbiquityIdetityTokenUUID)
    }
}


// MARK: - User Account Token for Local Use

extension CoreDataStack {
    
    typealias UbiquityIdentityToken = (NSCoding & NSCopying & NSObjectProtocol)
    
    static let kUserUbiquityIdentityTokenDict = "CoreDataStack.kUserUbiquityIdentityTokenDict"
    static let kNoUserUbiquityIdentityTokenUUID = "CoreDataStack.kNoUserUbiquityIdentityTokenUUID"
    static let kLastUserUbiquityIdetityTokenUUID = "CoreDataStack.kLastUserUbiquityIdetityTokenUUID"
    
    
    static func getUserIdentityTokenUUID(for token: UbiquityIdentityToken?) -> String {
        initializeUserUbiquityIdentityTokenDictionary()
        
        let userDefaults = UserDefaults.standard
        var tokenDict = userDefaults.value(forKey: kUserUbiquityIdentityTokenDict) as! [String: UbiquityIdentityToken]
        
        guard let token = token else { return userDefaults.string(forKey: kNoUserUbiquityIdentityTokenUUID)! }
        
        // find uuid from the dictionary
        for (tokenUUID, ubiquityToken) in tokenDict where ubiquityToken.isEqual(token) {
            return tokenUUID
        }
        
        // if does not exist, create one and store it
        let newTokenUUID = UUID().uuidString
        tokenDict[newTokenUUID] = token
        userDefaults.setValue(tokenDict, forKey: kUserUbiquityIdentityTokenDict)
        
        return newTokenUUID
    }
    
    static func initializeUserUbiquityIdentityTokenDictionary() {
        let userDefaults = UserDefaults.standard
        guard userDefaults.value(forKey: kUserUbiquityIdentityTokenDict) == nil else { return }
        let dict = [String: UbiquityIdentityToken]()
        userDefaults.setValue(dict, forKey: kUserUbiquityIdentityTokenDict)
        userDefaults.setValue(UUID().uuidString, forKey: kNoUserUbiquityIdentityTokenUUID)
    }
}

