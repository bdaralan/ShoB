//
//  SaleItemFormBody.swift
//  ShoB
//
//  Created by Dara Beng on 7/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// The body view of the sale item form.
struct SaleItemFormBody: View {
    
    @Binding var model: SaleItemFormModel
    
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
        Group {
            // MARK: Name & Price
            Group {
                VertialTextField("Name", placeholder: nameTextFieldPlaceholder, text: $model.name)
                VertialTextField("Price", placeholder: "$0.00", text: $model.price)
            }
            .disabled(!shouldEnableNamePriceTextFields)
            
            if mode == .orderItem {
                // MARK: Subtotal
                HStack {
                    Text("Subtotal").bold()
                    Spacer()
                    Text("\(model.subtotal)").bold()
                }
                
                HStack {
                    // MARK: Quantity
                    VStack(alignment: .leading) {
                        Text("\(model.quantity)")
                            .padding(.top, VertialTextField.topPadding)
                        Text("Quantity")
                            .font(.caption)
                            .foregroundColor(VertialTextField.labelColor)
                    }
                    
                    Spacer()
                    
                    HStack {
                        // MARK: Segment Picker
                        Picker("", selection: $quantityStepByValue) {
                            Text("1").tag(1)
                            Text("5").tag(5)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(minWidth: 100)
                        
                        // MARK: Stepper
                        Stepper("", value: $model.quantity, in: quantityStepperRange, step: quantityStepByValue)
                    }
                }
            }
        }
    }
}


extension SaleItemFormBody {
    
    enum Mode {
        case saleItem
        case orderItem
    }
}
