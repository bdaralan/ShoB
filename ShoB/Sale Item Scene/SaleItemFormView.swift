//
//  SaleItemFormView.swift
//  ShoB
//
//  Created by Dara Beng on 7/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct SaleItemFormView: View {
    
    @Binding var model: SaleItemFormModel
        
    var showQuantity: Bool
    
    @State private var quantityStepByValue = 1
    
    
    // MARK: - View Body
    
    var body: some View {
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
                    .tapAction { self.toggleQuantityStepByValue() }
                    
                    Stepper("", value: $model.quantity, in: 1...999, step: quantityStepByValue)
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
