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
    
    @State private var incrementValue = 1
    
    @State private var quantityMode = QuantityMode.unit
    
    var incrementRange: ClosedRange<Int> {
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
                orderItemModeInputView
            }
        }
    }
}


// MARK: - Order Item Mode Input View

extension SaleItemFormBody {
    
    var orderItemModeInputView: some View {
        Group {
            // MARK: Subtotal
            HStack {
                Text("Subtotal").bold()
                Spacer()
                Text("\(model.subtotal)").bold()
            }
            
            // MARK: Quantity
            HStack {
                Text("Quantity")
                Spacer()
                quantityText
            }
            
            HStack {
                // MARK: Unit Segment
                Picker("", selection: $quantityMode) {
                    Text("Unit").tag(QuantityMode.unit)
                    Text("Dozen").tag(QuantityMode.dozen)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // MARK: Increment Segment
                Picker("", selection: $incrementValue) {
                    Text("1").tag(1)
                    Text("5").tag(5)
                    Text("12").tag(QuantityMode.dozenCount)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // MARK: Stepper
                Stepper("", value: $model.quantity, in: incrementRange, step: incrementValue, onEditingChanged: { changing in
                    // if quantity is less then a dozen, switch back to unit segment
                    guard !changing, self.model.quantity < QuantityMode.dozenCount else { return }
                    self.quantityMode = .unit
                })
            }
        }
    }
    
    /// View that displays quantity based on `quantityMode`.
    var quantityText: Text {
        switch quantityMode {
        case .unit:
            return Text("\(model.quantity)")
        case .dozen:
            let dozen = model.quantity / QuantityMode.dozenCount
            let remain = model.quantity % QuantityMode.dozenCount
            let remainString = remain == 0 ? "" : " + \(remain)"
            return Text("\(dozen) ") + Text(QuantityMode.dozenAbbrev).fontWeight(.light).italic() + Text(remainString)
        }
    }
}


extension SaleItemFormBody {
    
    enum Mode {
        case saleItem
        case orderItem
    }
    
    enum QuantityMode {
        case unit
        case dozen
        
        static let dozenCount = 12
        static let dozenAbbrev = "doz."
    }
}
