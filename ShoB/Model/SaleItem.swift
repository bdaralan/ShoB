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
class SaleItem: NSManagedObject, Identifiable {
    
    @NSManaged var name: String
    @NSManaged var price: Cent
    @NSManaged var store: Store?
    
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
}


extension SaleItem {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<SaleItem> {
        return NSFetchRequest<SaleItem>(entityName: "SaleItem")
    }
}
