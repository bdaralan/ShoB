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
    
    @EnvironmentObject var customerDataSource: CustomerDataSource
    
    @State private var showCreateCustomerForm = false
    
    @State private var newCustomerModel = CustomerFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    @ObservedObject private var searchField = SearchField()
    
    var sortedCustomers: [Customer] {
        customerDataSource.fetchedResult.fetchedObjects?
            .sorted(by: { $0.identity.lowercased() < $1.identity.lowercased() }) ?? []
    }
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            SearchTextField(searchField: searchField)
            ForEach(sortedCustomers) { customer in
                CustomerRow(
                    customer: self.customerDataSource.readObject(customer),
                    onDeleted: { self.viewReloader.forceReload() }
                )
            }
        }
        .onAppear(perform: setupSearchField)
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
            self.customerDataSource.discardNewObject()
            self.customerDataSource.prepareNewObject()
            self.newCustomerModel = .init(customer: self.customerDataSource.newObject!)
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
        NavigationView {
            CustomerForm(
                model: $newCustomerModel,
                onCreate: saveNewCustomer,
                onCancel: dismissCreateNewCustomerForm,
                enableCreate: newCustomerModel.customer!.hasValidInputs()
            )
                .navigationBarTitle("New Customer", displayMode: .inline)
        }
    }
    
    func dismissCreateNewCustomerForm() {
        customerDataSource.discardCreateContext()
        showCreateCustomerForm = false
    }
    
    func saveNewCustomer() {
        customerDataSource.saveNewObject()
        showCreateCustomerForm = false
    }
}


// MARK: - Method

extension CustomerListView {
    
    func setupSearchField() {
        searchField.placeholder = "Search name, phone, email, etc..."
        searchField.onSearchTextDebounced = { searchText in
            let search = searchText.isEmpty ? nil : searchText
            self.customerDataSource.performFetch(Customer.requestAllCustomer(filterInfo: search))
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
