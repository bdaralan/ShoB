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
class SaleItem: NSManagedObject, BindableObject {
    
    let willChange = PassthroughSubject<Void, Never>()
    
    @NSManaged var name: String
    @NSManaged var price: Cent
    @NSManaged var store: Store?
    
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        willChange.send()
    }
}


extension SaleItem {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<SaleItem> {
        return NSFetchRequest<SaleItem>(entityName: "SaleItem")
    }
}
