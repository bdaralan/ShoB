//
//  OrderDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct OrderDetailView: View {
    
    @ObjectBinding var order: Order
    
    var onUpdate: () -> Void
    
    
    var body: some View {
        OrderForm(order: order)
            .navigationBarTitle("Order Details", displayMode: .inline)
            .navigationBarItems(trailing: updateOrderNavItem)
    }
    
    
    var updateOrderNavItem: some View {
        Button(action: onUpdate, label: { Text("Update").bold() })
            .disabled(!order.hasPersistentChangedValues)
    }
}

#if DEBUG
struct OrderDetailView_Previews : PreviewProvider {
    
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    
    static var previews: some View {
        OrderDetailView(order: order, onUpdate: {})
    }
}
#endif
