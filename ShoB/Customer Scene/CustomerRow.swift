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
        }
    }
}


// MARK: - Body Component

extension CustomerRow {
    
    var customerDetailView: some View {
        CustomerForm(
            model: $model,
            onUpdate: customerDataSource.saveUpdateObject,
            enableUpdate: customer.hasPersistentChangedValues && customer.hasValidInputs(),
            rowActions: [
                .init(title: "Delete", isDestructive: true, action: { self.showDeleteAlert = true })
            ]
        )
            .onAppear(perform: setupOnAppear)
            .navigationBarTitle("Customer Details", displayMode: .inline)
            .modifier(DeleteAlertModifer($showDeleteAlert, title: "Delete Customer", action: deleteCustomer))
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
    
    func deleteCustomer() {
        customerDataSource.delete(customer, saveContext: true)
        navigationState.pop()
        onDeleted?()
    }
}


struct CustomerRow_Previews: PreviewProvider {
    static let customer = Customer(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CustomerRow(customer: customer)
    }
}
