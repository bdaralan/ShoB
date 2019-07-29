//
//  CustomerDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays customer's details.
struct CustomerDetailView: View, EditableForm {
    
    @ObjectBinding var customer: Customer
    
    @Binding var model: CustomerForm.Model
    
    var onSave: () -> Void
    
    
    var body: some View {
        CustomerForm(model: $model)
            .navigationBarTitle("Customer Details", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem(title: "Update", enable: customer.hasPersistentChangedValues))
    }
}

#if DEBUG
struct CustomerDetailView_Previews: PreviewProvider {
    static let customer = Customer(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CustomerDetailView(customer: customer, model: .constant(.init()), onSave: {})
    }
}
#endif
