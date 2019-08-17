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
    
    var enableUpdate: Bool {
        (order.hasPersistentChangedValues || order.isMarkedValuesChanged) && order.hasValidInputs()
    }
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: orderDetailView, isActive: $navigationState.isPushed) { // row content
            OrderRowContentView(order: order)
        }
    }

    
    // MARK: - Body Component
    
    var orderDetailView: some View {
        OrderForm(
            model: $orderModel,
            onUpdate: orderDataSource.saveUpdateObject,
            enableUpdate: enableUpdate,
            rowActions: rowActions()
        )
            .navigationBarTitle("Order Details", displayMode: .inline)
            .onAppear(perform: setupOnAppear)
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
    
    func deleteOrder() {
        orderDataSource.delete(order, saveContext: true)
        navigationState.pop()
        onDeleted?()
    }
    
    func placeOrderAgain() {
        navigationState.pop()
        onOrderAgain?(order)
    }
    
    func rowActions() -> [MultiPurposeFormRowAction] {
        var actions = [MultiPurposeFormRowAction]()
        
        actions.append(.init(title: "Delete", isDestructive: true, action: deleteOrder))
        
        if onOrderAgain != nil {
            actions.append(.init(title: "Place Again", action: placeOrderAgain))
        }
        
        return actions
    }
}


#if DEBUG
struct OrderRow_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        OrderRow(order: order)
    }
}
#endif
