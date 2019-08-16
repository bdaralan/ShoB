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
    
    var onSave: (Order) -> Void
    
    var onDelete: (Order) -> Void
    
    var onOrderAgain: (Order) -> Void
    
    @State private var orderModel = OrderFormModel()
    
    @ObservedObject private var navigationState = NavigationStateHandler()
    
    
    // MARK: - Body
    
    var body: some View {
        navigationState.onPopped = {
            self.orderDataSource.setUpdateObject(nil)
            
            guard self.order.hasChanges, let context = self.order.managedObjectContext else { return }
            
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
            
            context.rollback()
        }
        
        return NavigationLink(destination: orderDetailView, isActive: $navigationState.isPushed) { // row content
            OrderRowContentView(order: order)
        }
    }

    
    // MARK: - Body Component
    
    var orderDetailView: some View {
        OrderDetailView(order: order, model: $orderModel, onSave: {
            self.onSave(self.order)
        }, onDelete: {
            self.navigationState.onPopped = nil
            self.navigationState.pop()
            self.onDelete(self.order)
        }, onOrderAgain: {
            self.navigationState.pop()
            self.onOrderAgain($0)
        })
        .onAppear {
            // DEVELOPER NOTE:
            // Do the assignment here for now until finding a better place for the assignment
            print("DEVELOPER NOTE: OrderRow.orderDetailView.onAppear")
            
            // assign the order to the model.
            self.orderModel = .init(order: self.order)
            self.orderDataSource.setUpdateObject(self.order)
        }
    }
}


#if DEBUG
struct OrderRow_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        OrderRow(order: order, onSave: { _ in }, onDelete: { _ in }, onOrderAgain: { _ in })
    }
}
#endif
