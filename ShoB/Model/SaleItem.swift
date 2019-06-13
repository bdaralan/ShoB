//
//  SaleItem+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class SaleItem: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var price: Int64
    @NSManaged var store: Store?
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        name = ""
        price = 0
    }
}


extension SaleItem {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<SaleItem> {
        return NSFetchRequest<SaleItem>(entityName: "SaleItem")
    }
}
