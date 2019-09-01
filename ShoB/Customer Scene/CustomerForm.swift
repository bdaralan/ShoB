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
    
    
    // MARK: - Body
    
    var body: some View {
        let form = Form {
            // MARK: Info Section
            Section(header: Text.topSection("INFO")) {
                VertialTextField("Given Name", text: $model.givenName, content: .givenName)
                VertialTextField("Family Name", text: $model.familyName, content: .familyName)
                VertialTextField("Organization", text: $model.organization, content: .organizationName)
            }
            
            // MARK: Contact Section
            Section(header: Text("CONTACT").padding(.top)) {
                VertialTextField("Phone", text: $model.phone, content: .telephoneNumber)
                VertialTextField("Email", text: $model.email, content: .emailAddress).autocapitalization(.none)
                VertialTextField("Address", text: $model.address, content: .fullStreetAddress)
            }
            
            setupRowActionSection()
        }
        
        return setupNavItems(forForm: form.eraseToAnyView())
    }
}


struct CustomerForm_Previews: PreviewProvider {
    static let model = CustomerFormModel()
    static var previews: some View {
        CustomerForm(model: .constant(model))
    }
}
