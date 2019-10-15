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
        !orderItems.isEmpty
    }
    
    func hasChangedValues() -> Bool {
        hasPersistentChangedValues || isMarkedValuesChanged
    }
}


extension Order {
    
    /// Copy necessary values from the an order to another order.
    /// - Important: The two orders MUST be from the same context.
    /// - Parameters:
    ///   - oldOrder: The order to copy values from.
    ///   - newOrder: The order to copy values to.
    static func again(oldOrder: Order, newOrder: Order) {
        // copy necessary values
        newOrder.discount = oldOrder.discount
        newOrder.note = oldOrder.note
        newOrder.customer = oldOrder.customer
        newOrder.store = oldOrder.store
        
        // copy delivery time but set the day to today
        let calendar = Calendar.current
        let today = Date.currentYMDHM
        let newDateComponents = calendar.dateComponents([.hour, .minute], from: oldOrder.deliverDate)
        let newDate = calendar.date(
            bySettingHour: newDateComponents.hour!,
            minute: newDateComponents.minute!,
            second: 0,
            of: today
        )
        newOrder.deliverDate = newDate
        
        // copy order items
        oldOrder.orderItems.forEach {
            let copyItem = OrderItem(context: newOrder.managedObjectContext!)
            copyItem.name = $0.name
            copyItem.price = $0.price
            copyItem.quantity = $0.quantity
            copyItem.order = newOrder
        }
    }
}


// MARK: - Fetch Request

extension Order {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }
    
    /// A request to fetch today orders.
    /// - Parameter storeID: The store ID.
    static func requestDeliverToday(storeID: String) -> NSFetchRequest<Order> {
        requestDeliver(from: Date.startOfToday(), to: Date.startOfToday(addingDay: 1), storeID: storeID)
    }
    
    /// A request to fetch orders from date to another date.
    /// - Parameters:
    ///   - startDate: The earliest date to be included.
    ///   - endDate: The latest date but NOT included. The default is `nil` which means no boundary.
    ///   - storeID: The store ID.
    static func requestDeliver(from startDate: Date, to endDate: Date? = nil, storeID: String) -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
        let deliverDate = #keyPath(Order.deliverDate)
        let storeUID = #keyPath(Order.store.uniqueID)
        
        if let endDate = endDate {
            let matchDateQuery = "\(deliverDate) >= %@ AND \(deliverDate) < %@"
            let matchDate = NSPredicate(format: matchDateQuery, startDate as NSDate, endDate as NSDate)
            request.predicate = NSCompoundPredicate(storeID: storeID, keyPath: storeUID, and: [matchDate])
        
        } else {
            let matchDateQuery = "\(deliverDate) >= %@"
            let matchDate = NSPredicate(format: matchDateQuery, startDate as NSDate)
            request.predicate = NSCompoundPredicate(storeID: storeID, keyPath: storeUID, and: [matchDate])
        }
        
        request.sortDescriptors = [.init(key: deliverDate, ascending: true)]
        
        return request
    }
    
    /// A request to fetch orders from the past day up to but not including today.
    /// - Parameters:
    ///   - fromPastDay: The number of days that have been passed. For instance, 7 means last week.
    ///   - storeID: The store ID.
    static func requestDeliver(fromPastDay: Int, storeID: String) -> NSFetchRequest<Order> {
        let request = Order.fetchRequest() as NSFetchRequest<Order>
        let deliverDate = #keyPath(Order.deliverDate)
        let storeUID = #keyPath(Order.store.uniqueID)
        
        let today = Date.startOfToday() as NSDate
        let pastDay = Date.startOfToday(addingDay: -fromPastDay) as NSDate
        
        let matchDateQuery = "\(deliverDate) >= %@ AND \(deliverDate) < %@"
        let matchDate = NSPredicate(format: matchDateQuery, pastDay, today)
        request.predicate = NSCompoundPredicate(storeID: storeID, keyPath: storeUID, and: [matchDate])
        
        request.sortDescriptors = [.init(key: deliverDate, ascending: false)]
        
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
