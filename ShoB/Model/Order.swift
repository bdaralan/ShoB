//
//  Order+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import SwiftUI
import Combine


/// An order of a store or a customer.
class Order: NSManagedObject, ObjectValidatable {
    
    @NSManaged var orderDate: Date!
    @NSManaged var deliverDate: Date!
    @NSManaged var deliveredDate: Date?
    @NSManaged var discount: Cent
    @NSManaged var note: String
    @NSManaged var orderItems: Set<OrderItem>
    @NSManaged var customer: Customer?
    @NSManaged var store: Store?
    
    /// A formatted string of deliver date. Example: 12-31-2019.
    ///
    /// Used to group date into section when using fetch controller.
    @NSManaged private(set) var deliverDateSection: String
    
    /// Used to manually mark order as has changes.
    var isMarkedValuesChanged = false

    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        orderDate = Date.currentYMDHM
        deliverDate = Date.currentYMDHM
    }
    
    override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        objectWillChange.send()
    }
    
    override func didChangeValue(forKey key: String) {
        // update deliverDateSection when deliverDate value changed
        if key == #keyPath(Order.deliverDate) {
            let deliverDateSection = #keyPath(Order.deliverDateSection)
            let value = Self.deliverDateSectionFormatter.string(from: deliverDate)
            setPrimitiveValue(value, forKey: deliverDateSection)
        }
        super.didChangeValue(forKey: key)
    }
    
    override func didSave() {
        super.didSave()
        isMarkedValuesChanged = false
    }
    
    
    /// The total after discount.
    func total() -> Cent {
        subtotal() - discount
    }
    
    /// The total before discount.
    func subtotal() -> Cent {
        orderItems.map({ $0.price * $0.quantity }).reduce(0, +)
    }
}


extension Order {
    
    func isValid() -> Bool {
        hasValidInputs() && store != nil
    }
    
    func hasValidInputs() -> Bool {
        !self.orderItems.isEmpty
    }
    
    func hasChangedValues() -> Bool {
        hasPersistentChangedValues || isMarkedValuesChanged
    }
}


// MARK: - Fetch Request

extension Order {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }
    
    static func requestDeliverToday(storeID: String) -> NSFetchRequest<Order> {
        requestDeliver(from: Date.startOfToday(), to: Date.startOfToday(addingDay: 1), storeID: storeID)
    }
    
    /// A request to fetch orders from date to another date.
    /// - Parameter startDate: The earliest date to be included.
    /// - Parameter endDate: The latest date but NOT included. The default is `nil` which means no boundary.
    static func requestDeliver(from startDate: Date, to endDate: Date? = nil, storeID: String) -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
    
        let deliverDate = #keyPath(Order.deliverDate)
        let storeUniqueID = #keyPath(Order.store.uniqueID)
        let matchStoreID = "\(storeUniqueID) == %@"
        
        if let endDate = endDate {
            let format = "\(deliverDate) >= %@ AND \(deliverDate) < %@ AND \(matchStoreID)"
            request.predicate = .init(format: format, startDate as NSDate, endDate as NSDate, storeID)
        } else {
            let format = "\(deliverDate) >= %@ AND \(matchStoreID)"
            request.predicate = .init(format: format, startDate as NSDate, storeID)
        }
        
        request.sortDescriptors = [
            .init(key: deliverDate, ascending: true)
        ]
        
        return request
    }
    
    /// A request to fetch orders from the past day up to but not including today.
    /// - Parameter fromPastDay: The number of days that have been passed. For instance, 7 means last week.
    static func requestDeliver(fromPastDay: Int, storeID: String) -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
        
        let today = Date.startOfToday() as NSDate
        let pastDay = Date.startOfToday(addingDay: -fromPastDay) as NSDate
        let deliverDate = #keyPath(Order.deliverDate)
        let storeUniqueID = #keyPath(Order.store.uniqueID)
        let matchStoreID = "\(storeUniqueID) == %@"
        request.predicate = .init(format: "\(deliverDate) >= %@ AND \(deliverDate) < %@ AND \(matchStoreID)", pastDay, today, storeID)
        
        request.sortDescriptors = [
            .init(key: deliverDate, ascending: false)
        ]
        
        return request
    }
    
    static func requestNoObject() -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
        request.predicate = .init(value: false)
        request.sortDescriptors = []
        return request
    }
}


extension Order {
    
    /// A formatter used to format `deliverDateSection`.
    static let deliverDateSectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy" // example: 12-31-2019
        return formatter
    }()
}
