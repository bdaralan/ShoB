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
    
    @ObservedObject var customer: Customer
    
    @Binding var model: CustomerFormModel
    
    var onSave: () -> Void
    
    var onDelete: () -> Void
    
    var isSaveEnabled: Bool {
        customer.hasPersistentChangedValues && customer.hasValidInputs()
    }
    
    @State private var showDeleteConfirmationAlert = false
    
    
    // MARK: - Body
    
    var body: some View {
        CustomerForm(model: $model, onDelete: { self.showDeleteConfirmationAlert = true })
            .navigationBarTitle("Customer Details", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem(title: "Update"))
            .alert(isPresented: $showDeleteConfirmationAlert, content: { self.deleteConfirmationAlert })
    }
}


// MARK: - Body Component

extension CustomerDetailView {
    
    var deleteConfirmationAlert: Alert {
        deleteConfirmationAlert(title: "Delete Customer", message: nil, action: onDelete)
    }
}


#if DEBUG
struct CustomerDetailView_Previews: PreviewProvider {
    static let customer = Customer(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CustomerDetailView(customer: customer, model: .constant(.init()), onSave: {}, onDelete: {})
    }
}
#endif
