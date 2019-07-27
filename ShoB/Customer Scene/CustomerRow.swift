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
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(maxWidth: 35, maxHeight: 35)
                    
                // MARK: Identity & Contact
                VStack(alignment: .leading, spacing: 4) {
                    identityText
                    Group {
                        organizationText
                        contactsText
                        addressText
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
        
        switch !phone.isEmpty || !email.isEmpty {
        
        case true where !phone.isEmpty && !email.isEmpty:
            return HStack {
                Image(systemName: "bubble.left")
                Text(phone)
                Divider()
                Image(systemName: "paperplane")
                Text(email)
            }
            .toAnyView()
        
        case true where !phone.isEmpty && email.isEmpty:
            return infoText(systemImage: "bubble.left", text: phone).toAnyView()
        
        case true where !email.isEmpty && phone.isEmpty:
            return infoText(systemImage: "paperplane", text: email).toAnyView()
            
        default: return EmptyView().toAnyView()
        }
    }
    
    var organizationText: some View {
        guard !customer.organization.isEmpty else { return EmptyView().toAnyView() }
        return infoText(systemImage: "briefcase", text: "\(customer.organization)").toAnyView()
    }
    
    var addressText: some View {
        guard !customer.contact.address.isEmpty else { return EmptyView().toAnyView() }
        return infoText(systemImage: "mappin.and.ellipse", text: "\(customer.contact.address)").toAnyView()
    }
    
    func infoText(systemImage name: String, text: String) -> some View {
        HStack {
            Image(systemName: name)
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
