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
                    infoText(image: Image.SFCustomer.organization, text: customer.organization)
                    infoText(image: Image.SFCustomer.phone, text: customer.phone)
                    infoText(image: Image.SFCustomer.email, text: customer.email)
                    infoText(image: Image.SFCustomer.address, text: customer.address)
                }
                .font(.caption)
            }
        }
    }
}


// MARK: - Body Component

extension CustomerRowContentView {
    
    /// Customer info view display an image and the info text.
    /// - Parameter image: Image represent the info.
    /// - Parameter text: Info text.
    func infoText(image: Image, text: String) -> some View {
        guard !text.isEmpty else { return AnyView.emptyView }
        return HStack {
            image
            Text(text.replaceEmpty(with: "N/A"))
        }
        .toAnyView()
    }
}
