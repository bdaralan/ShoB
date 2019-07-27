//
//  CustomerRow.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct CustomerRow: View {
    
    @ObjectBinding var customer: Customer
    
    @State private var model = CustomerForm.Model()
    
    var onSave: (CustomerForm.Model) -> Void
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: customerDetailView) { // row content
            HStack(alignment: .center, spacing: 15) {
                // MARK: Profile Image
                Image.SFCustomer.profile
                    .resizable()
                    .frame(maxWidth: 35, maxHeight: 35)
                    
                // MARK: Identity & Contact
                VStack(alignment: .leading, spacing: 4) {
                    identityText
                    Group {
                        if !customer.organization.isEmpty {
                            infoText(image: Image.SFCustomer.organization, text: "\(customer.organization)").toAnyView()
                        }
                        
                        contactsText
                        
                        if !customer.contact.address.isEmpty {
                            infoText(image: Image.SFCustomer.address, text: "\(customer.contact.address)").toAnyView()
                        }
                    }
                    .font(.caption)
                }
            }
        }
    }
    
    
    // MARK: - Body Component
    
    var customerDetailView: some View {
        CustomerDetailView(customer: customer, model: $model, onSave: {
            self.onSave(self.model)
        })
        .onAppear {
            self.model = .init(customer: self.customer)
        }
    }
    
    var identityText: some View {
        Text("\(customer.identity)").fontWeight(.semibold)
    }
    
    var contactsText: some View {
        let phone = customer.contact.phone
        let email = customer.contact.email
        
        switch !phone.isEmpty && !email.isEmpty {
        
        case true:
            return HStack {
                Image.SFCustomer.phone
                Text(phone)
                Divider()
                Image.SFCustomer.email
                Text(email)
            }
            .toAnyView()
        
        case false where !phone.isEmpty && email.isEmpty:
            return infoText(image: Image.SFCustomer.phone, text: phone).toAnyView()
        
        case false where !email.isEmpty && phone.isEmpty:
            return infoText(image: Image.SFCustomer.email, text: email).toAnyView()
            
        default: return EmptyView().toAnyView()
        }
    }
    
    func infoText(image: Image, text: String) -> some View {
        HStack {
            image
            Text(text.replaceEmpty(with: "N/A"))
        }
    }
}


#if DEBUG
struct CustomerRow_Previews: PreviewProvider {
    static let customer = Customer(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CustomerRow(customer: customer, onSave: { _ in })
    }
}
#endif
