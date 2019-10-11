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
    
    static func requestAllObjects(filterNameOrPrice: String? = nil) -> NSFetchRequest<SaleItem> {
        let request = SaleItem.fetchRequest() as NSFetchRequest<SaleItem>
        
        if let search = filterNameOrPrice {
            if Double(search) != nil { // matching price
                request.predicate = .init(format: "\(#keyPath(SaleItem.price)) == %d", Currency(search).amount)
            } else { // matching name
                request.predicate = .init(format: "\(#keyPath(SaleItem.name)) CONTAINS[c] %@", search)
            }
        } else {
            request.predicate = .init(value: true)
        }
        
        let sortByName = NSSortDescriptor(key: #keyPath(SaleItem.name), ascending: true)
        request.sortDescriptors = [sortByName]
        
        return request
    }
    
    static func requestObjects(storeID: String) -> NSFetchRequest<SaleItem> {
        let request = SaleItem.fetchRequest() as NSFetchRequest<SaleItem>
        let itemStoreID = #keyPath(SaleItem.store.uniqueID)
        let itemName = #keyPath(SaleItem.name)
        request.predicate = .init(format: "\(itemStoreID) == %@", storeID)
        request.sortDescriptors = [.init(key: itemName, ascending: true)]
        return request
    }
    
    static func requestNoObject() -> NSFetchRequest<SaleItem> {
        let request = SaleItem.fetchRequest() as NSFetchRequest<SaleItem>
        request.predicate = .init(value: false)
        request.sortDescriptors = []
        return request
    }
}
