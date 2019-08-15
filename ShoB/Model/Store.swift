//
//  Store+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import SwiftUI
import Combine


/// User's store.
///
/// An object that holds user's records including
/// sale items, orders, and customers.
///
class Store: NSManagedObject, Identifiable, ValidationRequired {
    
    @NSManaged var name: String
    @NSManaged var phone: String
    @NSManaged var email: String
    @NSManaged var address: String
    @NSManaged var saleItems: Set<SaleItem>
    @NSManaged var orders: Set<Order>
    @NSManaged var customers: Set<Customer>
    
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
    
    func hasValidInputs() -> Bool {
        !name.isEmpty
    }
    
    func isValid() -> Bool {
        hasValidInputs()
    }
}


extension Store {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Store> {
        return NSFetchRequest<Store>(entityName: "Store")
    }
    
    static func requestAllStores() -> NSFetchRequest<Store> {
        let request = Store.fetchRequest() as NSFetchRequest<Store>
        
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(Store.name), ascending: true)]
        
        return request
    }
}
