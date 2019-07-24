//
//  CustomerListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct CustomerListView: View {
    
    @EnvironmentObject var dataSource: FetchedDataSource<Customer>
    
    @State private var showCreateCustomerForm = false
    
    @State private var newCustomerModel = CustomerForm.Model()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(dataSource.fetchController.fetchedObjects ?? []) { customer in
                NavigationLink(destination: Text("Customer Info"), label: {
                    HStack {
                        Image(systemName: "person.crop.rectangle").imageScale(.large)
                        Text("\(customer.familyName) \(customer.givenName)")
                    }
                })
            }
        }
        .navigationBarItems(trailing: createNewCustomerNavItem)
        .sheet(
            isPresented: $showCreateCustomerForm,
            onDismiss: dismissCreateNewCustomerForm,
            content: { self.createCustomerForm }
        )
    }
    
    
    // MARK: - Bodh Component
    
    var createCustomerForm: some View {
        CreateCustomerForm(
            model: $newCustomerModel,
            onCreate: dismissCreateNewCustomerForm,
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
        .accentColor(.accentColor)
    }
    
    
    // MARK: - Method
    
    func dismissCreateNewCustomerForm() {
        dataSource.cud.discardCreateContext()
        showCreateCustomerForm = false
    }
}

#if DEBUG
struct CustomerList_Previews : PreviewProvider {
    static var previews: some View {
        CustomerListView()
    }
}
#endif
