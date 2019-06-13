//
//  Order+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class Order: NSManagedObject {
    
    @NSManaged var orderDate: Date
    @NSManaged var deliveryDate: Date
    @NSManaged var deliveredDate: Date?
    @NSManaged var discount: Int64
    @NSManaged var note: String
    @NSManaged var orderItems: Set<OrderItem>
    @NSManaged var customer: Customer?
    @NSManaged var store: Store?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        orderDate = Date()
        deliveryDate = Date()
        discount = 0
        note = ""
        orderItems = []
    }
}


extension Order {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }
}
