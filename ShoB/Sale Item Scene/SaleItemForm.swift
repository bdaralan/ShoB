//
//  SaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct SaleItemForm: View, MultiPurposeForm {
    
    @Binding var model: SaleItemFormModel
        
    var onCreate: (() -> Void)?
    
    var onUpdate: (() -> Void)?
    
    var onCancel: (() -> Void)?
    
    var enableCreate: Bool?
    
    var enableUpdate: Bool?
    
    var rowActions: [MultiPurposeFormRowAction] = []
    
    
    // MARK: - Body
    
    var body: some View {
        let form = Form {
            // MARK: Name & Price
            Section {
                VertialTextField("Name", text: $model.name)
                HStack {
                    Text("Price")
                    CurrencyTextField(text: $model.price)
                }
            }
            
            setupRowActionSection()
        }
        
        return setupNavItems(forForm: form.toAnyView())
    }
}
