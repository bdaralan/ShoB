//
//  CustomerRowContentView.swift
//  ShoB
//
//  Created by Dara Beng on 7/27/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// The content view of the customer row.
struct CustomerRowContentView: View {
    
    @ObservedObject var customer: Customer
    
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            // MARK: Profile Image
            Image.SFCustomer.profile
                .resizable()
                .frame(maxWidth: 35, maxHeight: 35)
            
            // MARK: Identity & Contact
            VStack(alignment: .leading, spacing: 4) {
                Text(customer.identity)
                    .fontWeight(.semibold)
                
                Group {
                    Text.contactInfo(image: Image.SFCustomer.organization, text: customer.organization)
                    Text.contactInfo(image: Image.SFCustomer.phone, text: customer.phone)
                    Text.contactInfo(image: Image.SFCustomer.email, text: customer.email)
                    Text.contactInfo(image: Image.SFCustomer.address, text: customer.address)
                }
                .font(.caption)
            }
        }
    }
}
