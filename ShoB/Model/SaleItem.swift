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
    
    static func requestAllObjects(searchNameOrPrice: String? = nil) -> NSFetchRequest<SaleItem> {
        let request = SaleItem.fetchRequest() as NSFetchRequest<SaleItem>
        
        if let search = searchNameOrPrice {
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
}
