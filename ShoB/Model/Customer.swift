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
class Customer: NSManagedObject, Identifiable {
    
    @NSManaged var familyName: String
    @NSManaged var givenName: String
    @NSManaged var organization: String
    @NSManaged var phone: String
    @NSManaged var email: String
    @NSManaged var address: String
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
    
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
}


// MARK: - Fetch Request

extension Customer {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }
    
    static func requestAllCustomer() -> NSFetchRequest<Customer> {
        let request = Customer.fetchRequest() as NSFetchRequest<Customer>
        request.predicate = .init(value: true)
        request.sortDescriptors = []
        return request
    }
}
