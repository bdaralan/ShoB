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
        didSet { assign(to: [.name]) }
    }
    
    @CurrencyWrapper(amount: 0)
    var price: String {
        didSet { assign(to: [.price]) }
    }
    
    var quantity = 1 {
        didSet { assign(to: [.quantity]) }
    }
    
    
    init() {}
    
    init(item: SaleItem? = nil) {
        guard let item = item else { return }
        self.saleItem = item
        name = item.name
        price = "\(Currency(item.price))"
        quantity = 1 // default to 1 when create item
    }
        
    init(item: OrderItem? = nil) {
        guard let item = item else { return }
        self.orderItem = item
        name = item.name
        price = "\(Currency(item.price))"
        quantity = Int(64)
    }
    
    
    func assign(to item: SaleItem, keys: [Key] = Key.allCases) {
        for key in keys {
            switch key {
            case .name: item.name = name
            case .price: item.price = _price.amount
            default: break
            }
        }
    }
    
    func assign(to item: OrderItem, keys: [Key] = Key.allCases) {
        for key in keys {
            switch key {
            case .name: item.name = name
            case .price: item.price = _price.amount
            case .quantity: item.quantity = Int64(quantity)
            }
        }
    }
    
    private func assign(to keys: [Key] = Key.allCases) {
        if let saleItem = saleItem, orderItem == nil {
            assign(to: saleItem, keys: keys)
        
        } else if let orderItem = orderItem, saleItem == nil {
            assign(to: orderItem, keys: keys)
        }
    }
        
        
    enum Key: CaseIterable {
            case name
            case price
            case quantity
        }
    }
