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
            mode == .saleItem
        }
        
        var nameTextFieldPlaceholder: String {
            mode == .saleItem ? "Name" : "Select an item"
        }
        
        
        // MARK: - Body
        
        var body: some View {
            Section {
                // MARK: Name & Price
                Group {
                    VertialTextField(nameTextFieldPlaceholder, text: $model.name)
                    VertialTextField("Price", placeholder: "$0.00", text: $model.price)
                }
                .disabled(!shouldEnableNamePriceTextFields)
                
                // MARK: Subtotal & Quatity
                if mode == .orderItem {
                    // Subtotal
                    HStack {
                        Text("Subtotal").bold()
                        Spacer()
                        Text("\(model.subtotal)").bold()
                    }
                    
                    HStack {
                        // Quantity
                        VStack(alignment: .leading) {
                            Text("\(model.quantity)")
                                .padding(.top, VertialTextField.topPadding)
                            Text("Quantity")
                                .font(.caption)
                                .foregroundColor(VertialTextField.labelColor)
                        }
                        
                        Spacer()
                        
                        // SegmentControl and Stepper
                        HStack {
                            quantityStepByValueSegmentControl
                            Stepper("", value: $model.quantity, in: quantityStepperRange, step: quantityStepByValue)
                        }
                    }
                }
            }
        }
        
        
        // MARK: - Body Component
        
        var quantityStepByValueSegmentControl: some View {
            SegmentedControl(selection: $quantityStepByValue) {
                ForEach([1, 5]) { stepValue in
                    Text("\(stepValue)").tag(stepValue)
                }
            }
            .frame(minWidth: 100)
        }
    }
    
    enum Mode {
        case saleItem
        case orderItem
    }
}
