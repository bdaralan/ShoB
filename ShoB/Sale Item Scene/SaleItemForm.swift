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
    
    @State private var quantityStepBy = 1
    
    
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
                
                HStack {
                    Text("Quantity")
                    Spacer()
                    Text("\(model.quantity)")
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Step By: \(quantityStepBy)")
                        Text("Tap here to change the step value")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }.tapAction {
                        self.toggleQuantityStepperStepByValue()
                    }
                    Stepper("", value: $model.quantity, in: 1...999, step: quantityStepBy)
                }
            }
        }
    }
    
    
    func toggleQuantityStepperStepByValue() {
        switch quantityStepBy {
        case 1: quantityStepBy = 5
        case 5: quantityStepBy = 10
        default: quantityStepBy = 1
        }
    }
}


// MARK: - View Model

extension SaleItemForm {
    
    struct Model {
        weak var item: SaleItem?
        weak var orderItem: OrderItem?
        
        var name = ""
        var price = ""
        var quantity = 0
        
        
        init() {}
        
        init(item: SaleItem? = nil) {
            guard let item = item else { return }
            self.item = item
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
        
        
        /// Assign model's values to either the `item` or `orderItem`.
        ///
        /// How the assignment works.
        /// - Assign to `item` if `orderItem` is `nil`.
        /// - Assign to `orderItem` if `item` is `nil`.
        /// - Otherwise the method does nothing.
        func assign() {
            if let item = item, orderItem == nil {
                item.name = name
                item.price = Currency.parseCent(from: price)
                return
            }
            
            if let orderItem = orderItem, item == nil {
                orderItem.name = name
                orderItem.price = Currency.parseCent(from: price)
                orderItem.quantity = Int64(quantity)
                return
            }
        }
    }
}


#if DEBUG
struct SaleItemForm_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemForm(model: .constant(.init()))
    }
}
#endif
