//
//  OrderItem+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import SwiftUI
import Combine


/// An item of an order.
class OrderItem: NSManagedObject, BindableObject {
    
    let willChange = PassthroughSubject<Void, Never>()
    
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
    
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        willChange.send()
    }
}


extension OrderItem {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<OrderItem> {
        return NSFetchRequest<OrderItem>(entityName: "OrderItem")
    }
}
