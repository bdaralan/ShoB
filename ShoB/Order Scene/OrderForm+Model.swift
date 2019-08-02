//
//  OrderForm+Model.swift
//  ShoB
//
//  Created by Dara Beng on 7/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


extension OrderForm {
    
    struct Model {
        weak var order: Order?
        
        var isDelivering = false {
            didSet { self.order?.deliveryDate = isDelivering ? Date.currentYMDHM : nil }
        }
        
        var isDelivered = false {
            didSet { self.order?.deliveredDate = isDelivered ? Date.currentYMDHM : nil }
        }
        
        var orderDate = Date.currentYMDHM {
            didSet { self.order?.orderDate = orderDate }
        }
        
        var deliveryDate = Date.currentYMDHM {
            didSet { self.order?.deliveryDate = deliveryDate }
        }
        
        var deliveredDate = Date.currentYMDHM {
            didSet { self.order?.deliveredDate = deliveredDate }
        }
        
        @CurrencyWrapper(amount: 0)
        var discount: String {
            didSet { self.order?.discount = _discount.amount }
        }
        
        var note = "" {
            didSet { self.order?.note = note }
        }
        
        
        init(order: Order? = nil) {
            guard let order = order else { return }
            self.order = order
            orderDate = order.orderDate
            isDelivering = order.deliveryDate != nil
            isDelivered = order.deliveredDate != nil
            deliveryDate = isDelivering ? order.deliveryDate! : Date.currentYMDHM
            deliveredDate = isDelivered ? order.deliveredDate! : Date.currentYMDHM
            discount = order.discount == 0 ? "" : "\(Currency(order.discount))"
            note = order.note
        }
    }
}


extension OrderForm.Model {
    
    /// Total before discount.
    var totalBeforeDiscount: String {
        guard let order = order else { return "\(Currency(0))" }
        return "\(Currency(order.total))"
    }
    
    /// Total after discount.
    var totalAfterDiscount: String {
        guard let order = order else { return "\(Currency(0))" }
        return "\(Currency(order.total - order.discount))"
    }
}
