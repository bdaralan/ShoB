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
        let matchStore = NSPredicate(format: "\(keyPath) == %@", storeID)
        let subPredicates = [matchStore] + predicates
        self.init(andPredicateWithSubpredicates: subPredicates)
    }
}
