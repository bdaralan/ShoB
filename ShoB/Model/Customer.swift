//
//  Customer+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import SwiftUI
import Combine


/// A customer of a store.
class Customer: NSManagedObject, BindableObject {
    
    let willChange = PassthroughSubject<Void, Never>()
    
    @NSManaged var familyName: String
    @NSManaged var givenName: String
    @NSManaged var organization: String
    @NSManaged var contact: Contact
    @NSManaged var orders: Set<Order>
    @NSManaged var store: Store?
    
    /// Customer's name or organization.
    var identity: String {
        let formatter = PersonNameComponentsFormatter()
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        let identity = formatter.string(from: components)
        return identity.isEmpty ? organization : identity
    }
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        familyName = ""
        givenName = ""
        organization = ""
        orders = []
        contact = Contact(context: managedObjectContext!)
    }
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        willChange.send()
    }
}


extension Customer {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }
}
