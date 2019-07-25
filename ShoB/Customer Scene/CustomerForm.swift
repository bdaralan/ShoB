//
//  CustomerForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct CustomerForm: View {
    
    @Binding var model: Model
    
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // MARK: Info Section
            Section(header: Text.topSection("INFO"), footer: Text("One of the above fields must not be empty.")) {
                VertialTextField("Given Name", text: $model.givenName, content: .givenName)
                VertialTextField("Family Name", text: $model.familyName, content: .familyName)
                VertialTextField("Organization", text: $model.organization, content: .organizationName)
            }
            
            // MARK: Contact Section
            Section(header: Text("CONTACT").padding(.top)) {
                VertialTextField("Phone", text: $model.phone, content: .telephoneNumber)
                VertialTextField("Email", text: $model.email, content: .emailAddress)
                VertialTextField("Address", text: $model.address, content: .fullStreetAddress)
            }
        }
    }
}


#if DEBUG
struct CustomerForm_Previews: PreviewProvider {
    static let model = CustomerForm.Model()
    static var previews: some View {
        CustomerForm(model: .constant(model))
    }
}
#endif
