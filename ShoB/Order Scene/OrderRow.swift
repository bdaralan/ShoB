//
//  OrderRow.swift
//  ShoB
//
//  Created by Dara Beng on 6/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays order in a list row.
struct OrderRow: View {
    
    @EnvironmentObject var orderDataSource: OrderDataSource
    
    @EnvironmentObject var customerDataSource: CustomerDataSource
    
    /// The order to view or update.
    @ObservedObject var order: Order
    
    var onDeleted: (() -> Void)?
    
    var onOrderAgain: ((Order) -> Void)?
    
    @State private var orderModel = OrderFormModel()
    
    @ObservedObject private var navigationState = NavigationStateHandler()
    
    @State private var showDeleteAlert = false
    
    var enableUpdate: Bool {
        (order.hasPersistentChangedValues || order.isMarkedValuesChanged) && order.isValid()
    }
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: orderDetailView, isActive: $navigationState.isPushed) { // row content
            OrderRowContentView(order: order)
                .contextMenu(menuItems: contextMenuItems)
        }
        .modifier(DeleteAlertModifer($showDeleteAlert, title: "Delete Order", action: deleteOrder))
    }

    
    // MARK: - Body Component
    
    var orderDetailView: some View {
        OrderForm(
            model: $orderModel,
            onUpdate: updateOrder,
            enableUpdate: enableUpdate,
            rowActions: []
        )
            .onAppear(perform: setupOnAppear)
            .navigationBarTitle("Order Details", displayMode: .inline)
    }
    
    func setupOnAppear() {
        // DEVELOPER NOTE:
        // Do the assignment here for now until finding a better place for the assignment
        print("DEVELOPER NOTE: OrderRow.orderDetailView.onAppear")
        
        // assign the order to the model.
        orderModel = .init(order: order)
        orderDataSource.setUpdateObject(order)
        
        navigationState.onPopped = {
            self.orderDataSource.setUpdateObject(nil)
            
            guard self.order.hasChanges || self.order.isMarkedValuesChanged else { return }
            guard let context = self.order.managedObjectContext else { return }
            
            // DEVELOPER NOTE: beta 5
            // customer and sale item does not need this on popped to
            // let make the list UI fresh
            //
            // but maybe because order present an addition view to add the item
            // which may lead to this behavior
            //
            // however, in commit 32539d0 before the refactoring of OrderRowContentView,
            // there was no need to send change ¯\(°_o)/¯
            self.order.objectWillChange.send()
            self.order.isMarkedValuesChanged = false
            
            context.rollback()
        }
    }
    
    /// Save order's changes.
    func updateOrder() {
        let result = orderDataSource.saveUpdateObject()
        switch result {
        case .saved, .unchanged: break
        case .failed:
            print("failed to update order \(orderDataSource.updateObject?.description ?? "nil")")
        }
    }
    
    func deleteOrder() {
        orderDataSource.delete(order, saveContext: true)
        onDeleted?()
    }
    
    func placeOrderAgain() {
        onOrderAgain?(order)
    }
    
    func confirmDelete() {
        showDeleteAlert = true
    }
    
    func contextMenuItems() -> some View {
        Group {
            Button(action: placeOrderAgain) {
                Text("Place Order Again")
                Image(systemName: "plus.square.on.square")
            }
            Button(action: confirmDelete) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}


struct OrderRow_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        OrderRow(order: order)
    }
}
