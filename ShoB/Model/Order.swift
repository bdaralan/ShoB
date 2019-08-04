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
class Order: NSManagedObject, Identifiable {
    
    @NSManaged var orderDate: Date!
    @NSManaged var deliverDate: Date!
    @NSManaged var deliveredDate: Date?
    @NSManaged var discount: Cent
    @NSManaged var note: String
    @NSManaged var orderItems: Set<OrderItem>
    @NSManaged var customer: Customer?
    @NSManaged var store: Store?
    
    var total: Cent {
        return orderItems.map({ $0.price * $0.quantity }).reduce(0, +)
    }
    
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
}


extension Order {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }
    
    static func requestDeliverToday() -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) as NSDate
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today as Date)! as NSDate
        
        let deliverDate = #keyPath(Order.deliverDate)
        let sortByDeliverDate = NSSortDescriptor(key: deliverDate, ascending: true)
        
        request.predicate = .init(format: "\(deliverDate) >= %@ AND \(deliverDate) < %@", today, tomorrow)
        request.sortDescriptors = [sortByDeliverDate]
        return request
    }
    
    static func requestDeliverTomorrow() -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)! as NSDate
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)! as NSDate
        
        let deliverDate = #keyPath(Order.deliverDate)
        let sortByDeliverDate = NSSortDescriptor(key: deliverDate, ascending: true)
        
        request.predicate = .init(format: "\(deliverDate) >= %@ AND \(deliverDate) < %@", tomorrow, dayAfterTomorrow)
        request.sortDescriptors = [sortByDeliverDate]
        return request
    }
    
    static func requestDeliveredPast7Days() -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) as NSDate
        let past7Day = calendar.date(byAdding: .day, value: -7, to: today as Date)! as NSDate
        
        let deliverDate = #keyPath(Order.deliverDate)
        let sortByDeliverDate = NSSortDescriptor(key: deliverDate, ascending: false)
        
        request.predicate = .init(format: "\(deliverDate) >= %@ AND \(deliverDate) < %@", past7Day, today)
        request.sortDescriptors = [sortByDeliverDate]
        return request
    }
}
