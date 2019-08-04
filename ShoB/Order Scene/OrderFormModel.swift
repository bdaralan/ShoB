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
        didSet { self.order?.deliveredDate = isDelivered ? Date.currentYMDHM : nil }
    }
    
    var orderDate = Date.currentYMDHM {
        didSet { self.order?.orderDate = orderDate }
    }
    
    var deliverDate = Date.currentYMDHM {
        didSet { self.order?.deliverDate = deliverDate }
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
        deliverDate = order.deliverDate
        isDelivered = order.deliveredDate != nil
        deliveredDate = isDelivered ? order.deliveredDate! : Date.currentYMDHM
        discount = order.discount == 0 ? "" : "\(Currency(order.discount))"
        note = order.note
    }
}


extension OrderFormModel {
    
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
