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
class Order: NSManagedObject, Identifiable, InStoreObject {
    
    @NSManaged var orderDate: Date!
    @NSManaged var deliverDate: Date!
    @NSManaged var deliveredDate: Date?
    @NSManaged var discount: Cent
    @NSManaged var note: String
    @NSManaged var orderItems: Set<OrderItem>
    @NSManaged var customer: Customer?
    @NSManaged var store: Store?
    
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
    
    
    /// The total after discount.
    func total() -> Cent {
        subtotal() - discount
    }
    
    /// The total before discount.
    func subtotal() -> Cent {
        orderItems.map({ $0.price * $0.quantity }).reduce(0, +)
    }
}


// MARK: - Fetch Request

extension Order {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }
    
    static func requestDeliverToday() -> NSFetchRequest<Order> {
        requestDeliver(from: Date.startOfToday(), endDate: Date.startOfToday(addingDay: 1))
    }
    
    /// A request to fetch orders from date to another date.
    /// - Parameter startDate: The earliest date to be included.
    /// - Parameter endDate: The latest date but NOT included. The default is `nil` which means no boundary.
    static func requestDeliver(from startDate: Date, endDate: Date? = nil) -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
    
        let deliverDate = #keyPath(Order.deliverDate)
        
        if let endDate = endDate {
            let format = "\(deliverDate) >= %@ AND \(deliverDate) < %@"
            request.predicate = .init(format: format, startDate as NSDate, endDate as NSDate)
        } else {
            let format = "\(deliverDate) >= %@"
            request.predicate = .init(format: format, startDate as NSDate)
        }
        
        request.sortDescriptors = [
            .init(key: deliverDate, ascending: true)
        ]
        
        return request
    }
    
    /// A request to fetch orders from the past day up to but not including today.
    /// - Parameter fromPastDay: The number of days that have been passed. For instance, 7 means last week.
    static func requestDeliver(fromPastDay: Int) -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
        
        let today = Date.startOfToday() as NSDate
        let pastDay = Date.startOfToday(addingDay: -fromPastDay) as NSDate
        let deliverDate = #keyPath(Order.deliverDate)
        request.predicate = .init(format: "\(deliverDate) >= %@ AND \(deliverDate) < %@", pastDay, today)
        
        request.sortDescriptors = [
            .init(key: deliverDate, ascending: false)
        ]
        
        return request
    }
}
