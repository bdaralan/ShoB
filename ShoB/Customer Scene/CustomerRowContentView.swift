//
//  CustomerRowContentView.swift
//  ShoB
//
//  Created by Dara Beng on 7/27/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct CustomerRowContentView: View {
    
    @ObjectBinding var customer: Customer
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            // MARK: Profile Image
            Image.SFCustomer.profile
                .resizable()
                .frame(maxWidth: 35, maxHeight: 35)
            
            // MARK: Identity & Contact
            VStack(alignment: .leading, spacing: 4) {
                Text("\(customer.identity)")
                    .fontWeight(.semibold)
                
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
struct CustomerRowContentView_Previews: PreviewProvider {
    static let customer = Customer()
    static var previews: some View {
        CustomerRowContentView(customer: customer)
    }
}
#endif
