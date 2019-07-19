//
//  SaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct SaleItemForm: View {
    
    @Binding var model: Model
    
    var showQuantity: Bool
    
    @State private var quantityStepByValue = 1
    
    
    // MARK: - View Body
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name")
                    TextField("Name", text: $model.name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Price")
                    TextField("$0.00", text: $model.price)
                        .multilineTextAlignment(.trailing)
                }
                
                if showQuantity {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("\(model.quantity)")
                    }
                    
                    HStack { // quantity stepper row
                        VStack(alignment: .leading) {
                            Text("Step By: \(quantityStepByValue)")
                            Text("Tap here to change the step value").font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .tapAction {
                            self.toggleQuantityStepByValue()
                        }
                        
                        Stepper("", value: $model.quantity, in: 1...999, step: quantityStepByValue)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Method
    
    func toggleQuantityStepByValue() {
        switch quantityStepByValue {
        case 1: quantityStepByValue = 5
        case 5: quantityStepByValue = 10
        default: quantityStepByValue = 1
        }
    }
}


// MARK: - View Model

extension SaleItemForm {
    
    struct Model {
        weak var saleItem: SaleItem?
        weak var orderItem: OrderItem?
        
        var name = "" {
            didSet { assign(to: .name) }
        }
        
        @CurrencyWrapper(amount: 0)
        var price: String {
            didSet { assign(to: .price) }
        }
        
        var quantity = 0 {
            didSet { assign(to: .quantity) }
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
        
        
        private func assign(to item: SaleItem, key: Key) {
            switch key {
            case .name: item.name = name
            case .price: item.price = _price.amount
            default: break
            }
            
            
        }
        
        private func assign(to item: OrderItem, key: Key) {
            switch key {
            case .name: item.name = name
            case .price: item.price = _price.amount
            case .quantity: item.quantity = Int64(quantity)
            }
        }
        
        private func assign(to key: Key) {
            if let saleItem = saleItem, orderItem == nil {
                assign(to: saleItem, key: key)
            
            } else if let orderItem = orderItem, saleItem == nil {
                assign(to: orderItem, key: key)
            }
        }
        
        
        enum Key {
            case name
            case price
            case quantity
        }
    }
}


#if DEBUG
struct SaleItemForm_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemForm(model: .constant(.init()), showQuantity: true)
    }
}
#endif
