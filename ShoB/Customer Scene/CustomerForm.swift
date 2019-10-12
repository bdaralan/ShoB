//
//  CustomerForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view used to view or edit customer.
struct CustomerForm: View, MultiPurposeForm {
    
    @Binding var model: CustomerFormModel
    
    var onCreate: (() -> Void)?
    
    var onUpdate: (() -> Void)?
    
    var onCancel: (() -> Void)?
    
    var enableCreate: Bool?
    
    var enableUpdate: Bool?
    
    var rowActions: [MultiPurposeFormRowAction] = []
    
    @State private var offsetY: CGFloat = 0
    
    
    // MARK: - Body
    
    var body: some View {
        let form = Form {
            // MARK: Info Section
            Section(header: Text.topSection("INFO")) {
                VerticalTextField(
                    text: $model.givenName,
                    label: "given name",
                    placeholder: "Given Name",
                    content: .givenName
                )
                VerticalTextField(
                    text: $model.familyName,
                    label: "family name",
                    placeholder: "Family Name",
                    content: .familyName
                )
                VerticalTextField(
                    text: $model.organization,
                    label: "organization",
                    placeholder: "Organization",
                    content: .organizationName
                )
            }
            
            // MARK: Contact Section
            Section(header: Text("CONTACT").padding(.top)) {
                VerticalTextField(
                    text: $model.phone,
                    label: "phone",
                    placeholder: "Phone",
                    content: .telephoneNumber,
                    onEditingChanged: updateOffsetY
                )
                    .keyboardType(.numberPad)
                VerticalTextField(
                    text: $model.email,
                    label: "email",
                    placeholder: "Email",
                    content: .emailAddress,
                    onEditingChanged: updateOffsetY
                )
                    .keyboardType(.emailAddress)
                VerticalTextField(
                    text: $model.address,
                    label: "address",
                    placeholder: "Address",
                    content: .fullStreetAddress,
                    onEditingChanged: updateOffsetY
                )
            }
            
            setupRowActionSection()
        }
        .offset(y: offsetY)
        
        return setupNavItems(forForm: form.eraseToAnyView())
    }
}


extension CustomerForm {
    
    func updateOffsetY(keyboardWillShow: Bool) {
        withAnimation {
            self.offsetY = keyboardWillShow ? -200 : 0
        }
    }
}


struct CustomerForm_Previews: PreviewProvider {
    static let model = CustomerFormModel()
    static var previews: some View {
        CustomerForm(model: .constant(model))
    }
}
