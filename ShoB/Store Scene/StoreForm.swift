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
                VertialTextField("Name", text: $model.name, content: .organizationName)
                VertialTextField("Phone", text: $model.phone, content: .telephoneNumber)
                VertialTextField("Email", text: $model.email, content: .emailAddress).autocapitalization(.none)
                VertialTextField("Address", text: $model.address, content: .fullStreetAddress)
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
