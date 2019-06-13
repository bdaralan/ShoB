//
//  Customer+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class Customer: NSManagedObject {
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var organization: String
    @NSManaged var contact: Contact
    @NSManaged var orders: Set<Order>
    @NSManaged var store: Store?
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        firstName = ""
        lastName = ""
        organization = ""
        orders = []
        contact = Contact(context: managedObjectContext!)
    }
}


extension Customer {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }
}
