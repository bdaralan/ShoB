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
class Customer: NSManagedObject, ObjectValidatable {
    
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


extension Customer {
    
    func isValid() -> Bool {
        hasValidInputs() && store != nil
    }
    
    func hasValidInputs() -> Bool {
        return !self.familyName.trimmed().isEmpty
            || !self.givenName.trimmed().isEmpty
            || !self.organization.trimmed().isEmpty
    }
    
    func hasChangedValues() -> Bool {
        hasPersistentChangedValues
    }
}


// MARK: - Fetch Request

extension Customer {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }
    
    /// A request to fetch customers.
    /// - Parameter predicate: Customer's info to filter. Example name, email, or address.
    static func requestObjects(storeID: String, withInfo predicate: String = "") -> NSFetchRequest<Customer> {
        let request = Customer.fetchRequest() as NSFetchRequest<Customer>
        let storeUID = #keyPath(store.uniqueID)
        
        let matchStore = NSPredicate(format: "\(storeUID) == %@", storeID)
        
        // fetch all objects when no predicate
        if predicate.isEmpty {
            request.predicate = matchStore
            request.sortDescriptors = []
            return request
        }
        
        // fetch all objects with predicate
        let infoQuery = """
        \(#keyPath(familyName)) CONTAINS[c] %@ OR
        \(#keyPath(givenName)) CONTAINS[c] %@ OR
        \(#keyPath(organization)) CONTAINS[c] %@ OR
        \(#keyPath(phone)) CONTAINS[c] %@ OR
        \(#keyPath(email)) CONTAINS[c] %@ OR
        \(#keyPath(address)) CONTAINS[c] %@
        """
        
        let matchInfo = NSPredicate(format: infoQuery, predicate, predicate, predicate, predicate, predicate, predicate)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [matchStore, matchInfo])
        request.sortDescriptors = []
        
        return request
    }
    
    static func requestNoObject() -> NSFetchRequest<Customer> {
        let request = Customer.fetchRequest() as NSFetchRequest<Customer>
        request.predicate = .init(value: false)
        request.sortDescriptors = []
        return request
    }
}
