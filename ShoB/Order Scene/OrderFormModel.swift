//
//  OrderFormModel.swift
//  ShoB
//
//  Created by Dara Beng on 7/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct OrderFormModel {
    
    weak var order: Order?
    
    var isDelivered = false {
        didSet {
            if isDelivered {
                deliveredDate = Date.currentYMDHM
                order?.deliveredDate = deliveredDate
            } else {
                order?.deliveredDate = nil
            }
        }
    }
    
    var orderDate = Date.currentYMDHM {
        didSet { order?.orderDate = orderDate }
    }
    
    var deliverDate = Date.currentYMDHM {
        didSet { order?.deliverDate = deliverDate }
    }
    
    var deliveredDate = Date.currentYMDHM {
        didSet { order?.deliveredDate = deliveredDate }
    }
    
    @CurrencyWrapper(amount: 0)
    var discount: String {
        didSet { order?.discount = _discount.amount }
    }
    
    var note = "" {
        didSet { order?.note = note }
    }
    
    /// The number of item in order.
    ///
    /// - Note: This property is used to force refresh UI only.
    ///
    ///   **In Beta 5**: While refactoring, there seem to be a bug in `OrderForm` class
    ///   where adding new item does not refresh "Place Order" button state even if
    ///   the order's `objectWillChange` is sent.
    ///
    ///   For now this property is used to force a UI refresh.
    ///
    ///   Revisit this in the future beta.
    var orderItemCount = 0
    
    
    init(order: Order? = nil) {
        guard let order = order else { return }
        self.order = order
        orderDate = order.orderDate
        deliverDate = order.deliverDate
        isDelivered = order.deliveredDate != nil
        deliveredDate = isDelivered ? order.deliveredDate! : Date.currentYMDHM
        discount = "\(Currency(order.discount))"
        note = order.note
        
        orderItemCount = order.orderItems.count
    }
}


extension OrderFormModel {
    
    /// Total before discount.
    var totalBeforeDiscount: String {
        guard let order = order else { return "\(Currency(0))" }
        return "\(Currency(order.subtotal()))"
    }
    
    /// Total after discount.
    var totalAfterDiscount: String {
        guard let order = order else { return "\(Currency(0))" }
        return "\(Currency(order.total()))"
    }
}
