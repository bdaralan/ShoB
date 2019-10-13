//
//  SaleItemFormModel.swift
//  ShoB
//
//  Created by Dara Beng on 7/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct SaleItemFormModel {
    
    weak var saleItem: SaleItem?
    
    weak var orderItem: OrderItem?
    
    var name = "" {
        didSet {
            saleItem?.name = name
            orderItem?.name = name
        }
    }
    
    @CurrencyWrapper(amount: 0)
    var price: String {
        didSet {
            saleItem?.price = _price.amount
            orderItem?.price = _price.amount
        }
    }
    
    var quantity = 0 {
        didSet { orderItem?.quantity = Int64(quantity) }
    }
    
    var subtotal: String {
        "\(Currency(_price.amount * Int64(quantity)))"
    }
    
    /// A flag to toggle the item selection list.
    ///
    /// The default is `true` which will show the selection list on present.
    /// - Note: Specifically use with `AddOrderItemForm`.
    var shouldExpandSelectionList = true
    
    
    /// Create a model with the item.
    /// - Parameter saleItem: The item to init with.
    /// - Parameter orderItem: The item to init with.
    /// - Parameter keepReference: Pass `true` to keep the item reference.
    ///   If `true`, the items are updated when the model is updated.
    init(saleItem: SaleItem? = nil, orderItem: OrderItem? = nil, keepReference: Bool = true) {
        if let item = saleItem {
            self.saleItem = keepReference ? item : nil
            name = item.name
            price = "\(Currency(item.price))"
            quantity = 0 // default to 0 when create item
        }
        
        if let item = orderItem {
            self.orderItem = keepReference ? item : nil
            name = item.name
            price = "\(Currency(item.price))"
            quantity = Int(item.quantity)
        }
    }
    
    
    func assign(to item: OrderItem) {
        item.name = name
        item.price = _price.amount
        item.quantity = Int64(quantity)
    }
}
