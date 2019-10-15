//
//  SaleItem+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import SwiftUI
import Combine


/// A sale item of a store.
class SaleItem: NSManagedObject, ObjectValidatable {
    
    @NSManaged var name: String
    @NSManaged var price: Cent
    @NSManaged var store: Store?
    
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
}


extension SaleItem {
    
    func isValid() -> Bool {
        hasValidInputs() && store != nil
    }
    
    func hasValidInputs() -> Bool {
        return !self.name.trimmed().isEmpty
            && self.price > 0
    }
    
    func hasChangedValues() -> Bool {
        hasPersistentChangedValues
    }
}


// MARK: - Fetch Request

extension SaleItem {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<SaleItem> {
        return NSFetchRequest<SaleItem>(entityName: "SaleItem")
    }
    
    static func requestObjects(storeID: String, withNameOrPrice predicate: String = "") -> NSFetchRequest<SaleItem> {
        let request = SaleItem.fetchRequest() as NSFetchRequest<SaleItem>
        let storeUID = #keyPath(SaleItem.store.uniqueID)
        let price = #keyPath(SaleItem.price)
        let name = #keyPath(SaleItem.name)
        
        // fetch all objects when no predicate
        if predicate.isEmpty {
            request.predicate = .init(storeID: storeID, keyPath: storeUID)
            request.sortDescriptors = [.init(key: name, ascending: true)]
            return request
        }
        
        // fetch all objects with predicate
        if Double(predicate) != nil { // matching price
            let currency = Currency(predicate)
            let matchPrice = NSPredicate(matchPrice: currency.amount, keyPath: price)
            request.predicate = NSCompoundPredicate(storeID: storeID, keyPath: storeUID, and: [matchPrice])
            request.sortDescriptors = [.init(key: price, ascending: true)]
            return request
        
        } else { // matching name
            let matchNameQuery = "\(name) CONTAINS[c] %@"
            let matchName = NSPredicate(format: matchNameQuery, predicate)
            request.predicate = NSCompoundPredicate(storeID: storeID, keyPath: storeUID, and: [matchName])
            request.sortDescriptors = [.init(key: name, ascending: true)]
            return request
        }
    }
    
    static func requestNoObject() -> NSFetchRequest<SaleItem> {
        let request = SaleItem.fetchRequest() as NSFetchRequest<SaleItem>
        request.predicate = .init(value: false)
        request.sortDescriptors = []
        return request
    }
}
