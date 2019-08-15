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
class Customer: NSManagedObject, Identifiable, ValidationRequired {
    
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
    
    func hasValidInputs() -> Bool {
        return !self.familyName.trimmed().isEmpty
            || !self.givenName.trimmed().isEmpty
            || !self.organization.trimmed().isEmpty
    }
    
    func isValid() -> Bool {
        hasValidInputs() && store != nil
    }
}


// MARK: - Fetch Request

extension Customer {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Customer> {
        return NSFetchRequest<Customer>(entityName: "Customer")
    }
    
    /// A request to fetch customers.
    /// - Parameter filterInfo: Customer's info to filter. Example name, email, or address.
    static func requestAllCustomer(filterInfo: String? = nil) -> NSFetchRequest<Customer> {
        let request = Customer.fetchRequest() as NSFetchRequest<Customer>
        
        if let search = filterInfo {
            let format = """
            \(#keyPath(familyName)) CONTAINS[c] %@ OR
            \(#keyPath(givenName)) CONTAINS[c] %@ OR
            \(#keyPath(organization)) CONTAINS[c] %@ OR
            \(#keyPath(phone)) CONTAINS[c] %@ OR
            \(#keyPath(email)) CONTAINS[c] %@ OR
            \(#keyPath(address)) CONTAINS[c] %@
            """
            request.predicate = .init(format: format, search, search, search, search, search, search)
        } else {
            request.predicate = .init(value: true)
        }
        
        request.sortDescriptors = []
        return request
    }
}
