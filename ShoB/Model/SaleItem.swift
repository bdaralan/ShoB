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
class SaleItem: NSManagedObject, Identifiable, InStoreObject {
    
    @NSManaged var name: String
    @NSManaged var price: Cent
    @NSManaged var store: Store?
    
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
}


// MARK: - Fetch Request

extension SaleItem {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<SaleItem> {
        return NSFetchRequest<SaleItem>(entityName: "SaleItem")
    }
    
    static func requestAllObjects() -> NSFetchRequest<SaleItem> {
        let request = SaleItem.fetchRequest() as NSFetchRequest<SaleItem>
        request.predicate = NSPredicate(value: true)
        
        let sortByName = NSSortDescriptor(key: #keyPath(SaleItem.name), ascending: true)
        request.sortDescriptors = [sortByName]
        
        return request
    }
}
