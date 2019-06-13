//
//  Store+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class Store: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var contact: Contact
    @NSManaged var saleItems: Set<SaleItem>
    @NSManaged var orders: Set<Order>
    @NSManaged var customers: Set<Customer>
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        name = ""
        saleItems = []
        orders = []
        customers = []
        contact = Contact(context: managedObjectContext!)
    }
}


extension Store {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Store> {
        return NSFetchRequest<Store>(entityName: "Store")
    }
}
