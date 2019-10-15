//
//  NSPredicate.swift
//  ShoB
//
//  Created by Dara Beng on 10/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension NSCompoundPredicate {
    
    /// A convenient method to create compound predicate to query with matching store ID.
    /// - Parameters:
    ///   - storeID: The store ID to match.
    ///   - keyPath: The key path of the store ID.
    ///   - predicates: The predicate to query.
    convenience init(storeID: String, keyPath: String, and predicates: [NSPredicate]) {
        let matchStore = NSPredicate(storeID: storeID, keyPath: keyPath)
        let subPredicates = [matchStore] + predicates
        self.init(andPredicateWithSubpredicates: subPredicates)
    }
}


extension NSPredicate {
    
    /// A convenient method to create compound predicate to query with matching store ID.
    /// - Parameters:
    ///   - storeID: The store ID to match.
    ///   - keyPath: The key path of the store ID.
    convenience init(storeID: String, keyPath: String) {
        self.init(format: "\(keyPath) == %@", storeID)
    }
    
    /// Creating a matching price predicate.
    ///
    /// This create a predicate that match the price between a lower and an upper range bounce.
    /// - Parameter price: The price to match.
    convenience init(matchPrice: Cent, keyPath: String) {
        let currency = Currency(matchPrice)
        let dollarInCent = currency.dollar * 100
        let remainCent = currency.cent
        let minAmount: Cent
        let maxAmount: Cent
        
        if remainCent > 9 { // range [10, 99]
            minAmount = dollarInCent + remainCent
            maxAmount = remainCent % 10 == 0 ? minAmount + 9 : minAmount
        
        } else if remainCent > 0 { // range [1, 9]
            minAmount = dollarInCent + remainCent
            maxAmount = minAmount
        
        } else if remainCent == 0 { // range [0, 0]
            minAmount = dollarInCent
            maxAmount = dollarInCent + 99
            
        } else {
            fatalError("🧨 cannot create predicate with negative number 💣")
        }
        
        self.init(format: "\(keyPath) BETWEEN {\(minAmount), \(maxAmount)}")
    }
}
