//
//  Contact+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class Contact: NSManagedObject {
    
    @NSManaged var address: String
    @NSManaged var email: String
    @NSManaged var phone: String
    
    @NSManaged private(set) var customer: Customer?
    @NSManaged private(set) var store: Store?
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        address = ""
        email = ""
        phone = ""
    }
}


extension Contact {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }
}
