//
//  OrderDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct OrderDetailView: View {
    
    /// The order to view or update.
    @ObjectBinding var order: Order
    
    /// Triggered when the order is updated.
    var onUpdated: () -> Void
    
    
    var body: some View {
        OrderForm(order: order)
            .navigationBarTitle("Order Details", displayMode: .inline)
            .navigationBarItems(trailing: updateOrderNavItem)
    }
    
    
    var updateOrderNavItem: some View {
        Button("Update", action: {
            self.order.managedObjectContext!.quickSave()
            self.order.didChange.send() // reload enabled state
            self.onUpdated()
        })
        .font(Font.body.bold())
        .disabled(!order.hasPersistentChangedValues)
    }
}

#if DEBUG
struct OrderDetailView_Previews : PreviewProvider {
    
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    
    static var previews: some View {
        OrderDetailView(order: order, onUpdated: {})
    }
}
#endif
