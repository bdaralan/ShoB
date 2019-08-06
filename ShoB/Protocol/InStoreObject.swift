//
//  InStoreObject.swift
//  ShoB
//
//  Created by Dara Beng on 8/6/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


/// A protocol that says an object belong to `Store` object.
protocol InStoreObject {
    
    /// The store the object belongs to.
    var store: Store? { get }
    
    /// Check if object is valid to save.
    func isValid() -> Bool
    
    /// Check if object has valid inputs from the user.
    func hasValidInputs() -> Bool
}


// MARK: - Default Implementation

extension InStoreObject {
    
    func isValid() -> Bool {
        hasValidInputs() && store != nil
    }
    
    func hasValidInputs() -> Bool {
        true
    }
}


// MARK: - Customer

extension InStoreObject where Self == Customer {
    
    func hasValidInputs() -> Bool {
        return !self.familyName.trimmed().isEmpty
            || !self.givenName.trimmed().isEmpty
            || !self.organization.trimmed().isEmpty
    }
}


// MARK: - Sale Item

extension InStoreObject where Self == SaleItem {
    
    func hasValidInputs() -> Bool {
        return !self.name.trimmed().isEmpty
            && self.price > 0
    }
}


// MARK: - Order

extension InStoreObject where Self == Order {
    
    func hasValidInputs() -> Bool {
        !self.orderItems.isEmpty
    }
}



