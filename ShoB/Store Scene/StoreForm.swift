//
//  StoreForm.swift
//  ShoB
//
//  Created by Dara Beng on 8/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct StoreForm: View, MultiPurposeForm {
    
    @ObservedObject var model: StoreFormModel
    
    var onCreate: (() -> Void)?
    
    var onUpdate: (() -> Void)?
    
    var onCancel: (() -> Void)?
    
    var enableCreate: Bool?
    
    var enableUpdate: Bool?
    
    var rowActions: [MultiPurposeFormRowAction] = []
    
    
    // MARK: - Body
    
    var body: some View {
        let form = Form {
            Section(header: Text.topSection("STORE INFO")) {
                VerticalTextField(
                    text: $model.name,
                    label: "name",
                    placeholder: "Name",
                    content: .organizationName
                )
                VerticalTextField(
                    text: $model.phone,
                    label: "phone",
                    placeholder: "Phone",
                    content: .telephoneNumber
                )
                    .keyboardType(.numberPad)
                VerticalTextField(
                    text: $model.email,
                    label: "email",
                    placeholder: "Email",
                    content: .emailAddress
                )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                VerticalTextField(
                    text: $model.address,
                    label: "address",
                    placeholder: "Address",
                    content: .fullStreetAddress
                )
            }
            
            setupRowActionSection()
        }
        
        return setupNavItems(forForm: form.eraseToAnyView())
    }
}


struct StoreForm_Previews: PreviewProvider {
    static var previews: some View {
        StoreForm(model: .init())
    }
}
