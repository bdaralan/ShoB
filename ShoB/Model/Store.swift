//
//  Store+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import CloudKit


/// User's store.
///
/// An object that holds user's records including
/// sale items, orders, and customers.
///
class Store: NSManagedObject, Identifiable, ValidationRequired {
    
    /// The owner's `CKRecord.ID`'s `recordName`.
    @NSManaged private(set) var ownerID: String
    @NSManaged var name: String
    @NSManaged var phone: String
    @NSManaged var email: String
    @NSManaged var address: String
    @NSManaged var saleItems: Set<SaleItem>
    @NSManaged var orders: Set<Order>
    @NSManaged var customers: Set<Customer>
    
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
    
    func hasValidInputs() -> Bool {
        !name.isEmpty
    }
    
    func isValid() -> Bool {
        hasValidInputs() && !ownerID.isEmpty
    }
    
    func setOwnerID(with recordID: CKRecord.ID) {
        guard recordID.zoneID.ownerName == CKCurrentUserDefaultName else { return }
        ownerID = recordID.recordName
    }
}


extension Store {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Store> {
        return NSFetchRequest<Store>(entityName: "Store")
    }
    
    static func requestAllStores() -> NSFetchRequest<Store> {
        let request = Store.fetchRequest() as NSFetchRequest<Store>
        
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(Store.name), ascending: true)]
        
        return request
    }
}


extension Store {
    
    static let kCurrentStoreDidChange = "Store.kCurrentStoreDidChange"
    
    /// Set the store as the current store.
    ///
    /// This method post a notification `kCurrentStoreDidChange`.
    ///
    /// The notification includes the store object from the main context or `nil`.
    /// - Parameter store: The store that will become current store.
    static func setCurrent(_ store: Store?) {
        AppCache.currentStoreURIData = store?.objectID.uriRepresentation().dataRepresentation
        
        let notificationName = Notification.Name(kCurrentStoreDidChange)
        guard let store = store else {
            NotificationCenter.default.post(name: notificationName, object: nil)
            return
        }
        
        let mainContext = CoreDataStack.current.mainContext
        let storeInMainContext = mainContext.object(with: store.objectID) as! Store
        NotificationCenter.default.post(name: notificationName, object: storeInMainContext)
    }
    
    /// The store that is set as current.
    ///
    /// - Important: The store object is from the main context.
    static func current() -> Store? {
        guard let uriData = AppCache.currentStoreURIData else { return nil }
        
        guard let uri = URL(dataRepresentation: uriData, relativeTo: nil) else { return nil }
        let coreDataStack = CoreDataStack.current
        let storeCoodinator = coreDataStack.persistentContainer.persistentStoreCoordinator
        let mainContext = coreDataStack.mainContext
        
        guard let objectID =  storeCoodinator.managedObjectID(forURIRepresentation: uri) else { return nil }
        let storeInMainContext = mainContext.object(with: objectID) as! Store
        return storeInMainContext
    }
    
    static func isCurrent(_ store: Store) -> Bool {
        store.objectID == current()?.objectID
    }
}
