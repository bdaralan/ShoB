//
//  CustomerRow.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays customer in a list row.
struct CustomerRow: View {
    
    @EnvironmentObject var customerDataSource: CustomerDataSource
    
    @ObservedObject var customer: Customer
    
    @State private var model = CustomerFormModel()
    
    @ObservedObject private var navigationState = NavigationStateHandler()
    
    var onDeleted: (() -> Void)?
    
    @State private var showDeleteAlert = false
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: customerDetailView, isActive: $navigationState.isPushed) {
            CustomerRowContentView(customer: customer)
                .contextMenu(menuItems: contextMenuItems)
        }
        .modifier(DeleteAlertModifer($showDeleteAlert, title: "Delete Customer", action: deleteCustomer))
    }
}


// MARK: - Body Component

extension CustomerRow {
    
    var customerDetailView: some View {
        CustomerForm(
            model: $model,
            onUpdate: updateCustomer,
            enableUpdate: customer.hasPersistentChangedValues && customer.isValid(),
            rowActions: []
        )
            .onAppear(perform: setupOnAppear)
            .navigationBarTitle("Customer Details", displayMode: .inline)
    }
    
    func setupOnAppear() {
        model = .init(customer: customer)
        customerDataSource.setUpdateObject(customer)
        
        navigationState.onPopped = {
            self.customerDataSource.setUpdateObject(nil)
            guard self.customer.hasChanges, let context = self.customer.managedObjectContext else { return }
            context.rollback()
        }
    }
    
    /// Save customer's changes.
    func updateCustomer() {
        let result = customerDataSource.saveUpdateObject()
        switch result {
        case .saved, .unchanged: break
        case .failed:
            print("failed to update order \(customerDataSource.updateObject?.description ?? "nil")")
        }
    }
    
    func deleteCustomer() {
        customerDataSource.delete(customer, saveContext: true)
        onDeleted?()
    }
    
    func confirmDelete() {
        showDeleteAlert = true
    }
    
    func contextMenuItems() -> some View {
        Group {
            Button(action: confirmDelete) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}


struct CustomerRow_Previews: PreviewProvider {
    static let customer = Customer(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CustomerRow(customer: customer)
    }
}
