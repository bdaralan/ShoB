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
    
    var onSave: (Customer) -> Void
    
    var onDelete: (Customer) -> Void
    
    
    // MARK: - Body
    
    var body: some View {
        // setup navigation view on popped logic
        navigationState.onPopped = { // discard unsaved changes
            self.customerDataSource.setUpdateObject(nil)
            guard self.customer.hasChanges, let context = self.customer.managedObjectContext else { return }
            context.rollback()
        }
        
        return NavigationLink(destination: customerDetailView, isActive: $navigationState.isPushed) {
            CustomerRowContentView(customer: customer)
        }
    }
}


// MARK: - Body Component

extension CustomerRow {
    
    var customerDetailView: some View {
        CustomerDetailView(customer: customer, model: $model, onSave: {
            self.onSave(self.customer)
        }, onDelete: {
            self.navigationState.onPopped = nil
            self.navigationState.isPushed = false
            self.onDelete(self.customer)
        })
        .onAppear {
            self.model = .init(customer: self.customer)
            self.customerDataSource.setUpdateObject(self.customer)
        }
    }
}


#if DEBUG
struct CustomerRow_Previews: PreviewProvider {
    static let customer = Customer(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CustomerRow(customer: customer, onSave: { _ in }, onDelete: { _ in })
    }
}
#endif
