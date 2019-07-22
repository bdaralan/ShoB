//
//  SaleItemForm+View.swift
//  ShoB
//
//  Created by Dara Beng on 7/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension SaleItemForm {
    
    struct BodyView: View {
        
        @Binding var model: SaleItemForm.Model
            
        let mode: Mode
        
        @State private var quantityStepByValue = 1
        
        var quantityStepperRange: ClosedRange<Int> {
            model.name.isEmpty ? 1...1 : 1...999
        }
        
        var shouldEnableNamePriceTextFields: Bool {
            mode == .createSaleItem
        }
        
        var nameTextFieldPlaceholder: String {
            mode == .createSaleItem ? "Name" : "Select an item"
        }
        
        
        // MARK: - Body
        
        var body: some View {
            Section {
                // MARK: Name & Price
                HStack {
                    Text("Name")
                    TextField(nameTextFieldPlaceholder, text: $model.name)
                        .multilineTextAlignment(.trailing)
                        .disabled(!shouldEnableNamePriceTextFields)
                }
                
                HStack {
                    Text("Price")
                    TextField("$0.00", text: $model.price)
                        .multilineTextAlignment(.trailing)
                        .disabled(!shouldEnableNamePriceTextFields)
                }
                
                // MARK: Subtotal & Quatity
                if mode == .addItemToOrder {
                    HStack {
                        Text("Subtotal").bold()
                        Spacer()
                        Text("\(model.subtotal)").bold()
                    }
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("\(model.quantity)")
                    }
                    
                    HStack { // quantity stepper row
                        Text("Tab here to change")
                            .foregroundColor(.secondary)
                            .tapAction { self.toggleQuantityStepByValue() }
                        
                        Spacer()
                        
                        Image(systemName: "\(self.quantityStepByValue).circle")
                            .imageScale(.large)
                            .foregroundColor(model.name.isEmpty ? .secondary : .primary)
                        
                        Stepper("", value: $model.quantity, in: quantityStepperRange, step: quantityStepByValue)
                    }
                }
            }
        }
        
        
        // MARK: - Method
        
        func toggleQuantityStepByValue() {
            quantityStepByValue = quantityStepByValue == 1 ? 5 : 1
        }
    }
    
    enum Mode {
        case createSaleItem
        case addItemToOrder
    }
}
