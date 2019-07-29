//
//  Order+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import SwiftUI
import Combine


/// An order of a store or a customer.
class Order: NSManagedObject, Identifiable {
    
    @NSManaged var orderDate: Date
    @NSManaged var deliveryDate: Date?
    @NSManaged var deliveredDate: Date?
    @NSManaged var discount: Cent
    @NSManaged var note: String
    @NSManaged var orderItems: Set<OrderItem>
    @NSManaged var customer: Customer?
    @NSManaged var store: Store?
    
    var total: Cent {
        return orderItems.map({ $0.price * $0.quantity }).reduce(0, +)
    }
    
    /// Used to manually mark order as has changes.
    var isMarkedValuesChanged = false

    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        orderDate = Date.currentYMDHM
    }
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        objectWillChange.send()
    }
}


extension Order {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }
}
