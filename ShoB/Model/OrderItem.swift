//
//  OrderItem+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class OrderItem: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var price: Cent
    @NSManaged var quantity: Int64
    @NSManaged var order: Order?
    
    var subtotal: Cent {
        price * quantity
    }
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        name = ""
        price = 0
        quantity = 0
    }
}


extension OrderItem {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<OrderItem> {
        return NSFetchRequest<OrderItem>(entityName: "OrderItem")
    }
}
