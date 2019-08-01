//
//  SaleItemForm+Model.swift
//  ShoB
//
//  Created by Dara Beng on 7/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension SaleItemForm {
    
    struct Model {
        
        weak var saleItem: SaleItem?
        
        weak var orderItem: OrderItem?
        
        var name = "" {
            didSet { assign(to: \Self.name) }
        }
        
        @CurrencyWrapper(amount: 0)
        var price: String {
            didSet { assign(to: \Self.price) }
        }
        
        var quantity = 1 {
            didSet { assign(to: \Self.quantity) }
        }
        
        var subtotal: String {
            "\(Currency(_price.amount * Int64(quantity)))"
        }
        
        
        init() {}
        
        /// Create a model with the item.
        /// - Parameter item: The item to init with.
        /// - Parameter keepReference: Pass `true` to keep the item reference.
        ///   If `true`, the item is updated when the model is updated.
        init(item: SaleItem? = nil, keepReference: Bool = true) {
            guard let item = item else { return }
            self.saleItem = keepReference ? item : nil
            name = item.name
            price = "\(Currency(item.price))"
            quantity = 1 // default to 1 when create item
        }
        
        init(item: OrderItem? = nil) {
            guard let item = item else { return }
            self.orderItem = item
            name = item.name
            price = "\(Currency(item.price))"
            quantity = Int(item.quantity)
        }
        
        
        func assign(to item: SaleItem, key: PartialKeyPath<Self>? = nil) {
            switch key {
            case \Self.name:
                item.name = name
            
            case \Self.price:
                item.price = _price.amount
            
            case .none:
                item.name = name
                item.price = _price.amount
            
            default: break
            }
        }
        
        func assign(to item: OrderItem, key: PartialKeyPath<Self>? = nil) {
            switch key {
            case \Self.name:
                item.name = name
            
            case \Self.price:
                item.price = _price.amount
            
            case \Self.quantity:
                item.quantity = Int64(quantity)
            
            case .none:
                item.name = name
                item.price = _price.amount
                item.quantity = Int64(quantity)
            
            default: break
            }
        }
        
        private func assign(to key: PartialKeyPath<Self>? = nil) {
            if let saleItem = saleItem, orderItem == nil {
                assign(to: saleItem, key: key)
                
            } else if let orderItem = orderItem, saleItem == nil {
                assign(to: orderItem, key: key)
            }
        }
    }
}
