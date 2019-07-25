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
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(maxWidth: 35, maxHeight: 35)
                    
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(customer.identity)")
                    Group {
                        customerInfoText(systemImage: "briefcase.fill", text: "\(customer.organization)")
                        customerInfoText(systemImage: "bubble.left.fill", text: "\(contactString(from: customer.contact))")
                        customerInfoText(systemImage: "house.fill", text: "\(customer.contact.address)")
                    }
                    .font(.caption)
                }
                
                Spacer()
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
    
    func customerInfoText(systemImage name: String, text: String) -> some View {
        HStack {
            Image(systemName: name)
            Text(text.replaceEmpty(with: "N/A"))
        }
    }
    
    
    // MARK: - Method
    
    func contactString(from contact: Contact) -> String {
        var contacts = [contact.phone, contact.email]
        contacts.removeAll(where: { $0.isEmpty })
        return contacts.joined(separator: " | ")
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
