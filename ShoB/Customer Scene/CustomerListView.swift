//
//  CustomerListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays store's customer in a list.
struct CustomerListView: View {
    
    @EnvironmentObject var dataSource: FetchedDataSource<Customer>
    
    @State private var showCreateCustomerForm = false
    
    @State private var newCustomerModel = CustomerFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    var sortedCustomers: [Customer] {
        dataSource.fetchController.fetchedObjects?
            .sorted(by: { $0.identity.lowercased() < $1.identity.lowercased() }) ?? []
    }
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(sortedCustomers) { customer in
                CustomerRow(
                    customer: customer.get(from: self.dataSource.cud.updateContext),
                    onSave: self.updateCustomer,
                    onDelete: self.deleteCustomer
                )
            }
        }
        .navigationBarItems(trailing: createNewCustomerNavItem)
        .sheet(
            isPresented: $showCreateCustomerForm,
            onDismiss: dismissCreateNewCustomerForm,
            content: { self.createCustomerForm }
        )
    }
}


// MARK: - Nav Item

extension CustomerListView {
    
    var createNewCustomerNavItem: some View {
        Button(action: {
            // discard and create a new object for the form
            self.dataSource.cud.discardNewObject()
            self.dataSource.cud.prepareNewObject()
            self.newCustomerModel = .init(customer: self.dataSource.cud.newObject!)
            self.showCreateCustomerForm = true
        }) {
            Image(systemName: "plus").imageScale(.large)
        }
    }
}


// MARK: - Create Customer Form

extension CustomerListView {
    
    /// A form for creating new customer.
    var createCustomerForm: some View {
        CreateCustomerForm(
            model: $newCustomerModel,
            onCreate: saveNewCustomer,
            onCancel: dismissCreateNewCustomerForm
        )
    }
    
    func dismissCreateNewCustomerForm() {
        dataSource.cud.discardCreateContext()
        showCreateCustomerForm = false
    }
    
    func saveNewCustomer() {
        dataSource.cud.saveCreateContext()
        showCreateCustomerForm = false
    }
}


// MARK: - Customer Row Method

extension CustomerListView {
    
    func updateCustomer(_ customer: Customer) {
        customer.objectWillChange.send()
        
        if customer.hasPersistentChangedValues {
            dataSource.cud.saveUpdateContext()
        } else {
            dataSource.cud.discardUpdateContext()
        }
    }
    
    func deleteCustomer(_ customer: Customer) {
        dataSource.cud.delete(customer, saveContext: true)
        viewReloader.forceReload()
    }
}


#if DEBUG
struct CustomerList_Previews : PreviewProvider {
    static var previews: some View {
        CustomerListView()
    }
}
#endif
