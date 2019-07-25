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
        NavigationLink(destination: customerDetailView) { // row context
            HStack {
                Image(systemName: "person.crop.rectangle").imageScale(.large)
                Text("\(customer.familyName) | \(customer.givenName) | \(customer.organization)")
                Text("\(customer.contact.phone)")
                Text("\(customer.contact.email)")
                Text("\(customer.contact.address)")
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
}

#if DEBUG
struct CustomerRow_Previews: PreviewProvider {
    static let customer = Customer(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CustomerRow(customer: customer, onSave: { _ in })
    }
}
#endif
