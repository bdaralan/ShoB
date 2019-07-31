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
    
    @State private var newCustomerModel = CustomerForm.Model()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(dataSource.fetchController.fetchedObjects ?? []) { customer in
                CustomerRow(
                    customer: customer.get(from: self.dataSource.cud.updateContext),
                    onSave: self.updateCustomer
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
    
    
    // MARK: - Body Component
    
    var createCustomerForm: some View {
        CreateCustomerForm(
            model: $newCustomerModel,
            onCreate: saveNewCustomer,
            onCancel: dismissCreateNewCustomerForm
        )
    }
    
    var createNewCustomerNavItem: some View {
        Button(action: {
            // discard and create a new order object for the form
            self.dataSource.cud.discardNewObject()
            self.dataSource.cud.prepareNewObject()
            self.newCustomerModel = .init(customer: self.dataSource.cud.newObject!)
            self.showCreateCustomerForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
    }
    
    
    // MARK: - Method
    
    func dismissCreateNewCustomerForm() {
        dataSource.cud.discardCreateContext()
        showCreateCustomerForm = false
    }
    
    func saveNewCustomer() {
        dataSource.cud.saveCreateContext()
        showCreateCustomerForm = false
    }
    
    func updateCustomer(_ model: CustomerForm.Model) {
        guard let customer = model.customer else { return }
        customer.objectWillChange.send()
        
        if customer.hasPersistentChangedValues {
            dataSource.cud.saveUpdateContext()
        } else {
            dataSource.cud.discardUpdateContext()
        }
    }
}

#if DEBUG
struct CustomerList_Previews : PreviewProvider {
    static var previews: some View {
        CustomerListView()
    }
}
#endif
