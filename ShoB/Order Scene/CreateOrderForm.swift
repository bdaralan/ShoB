//
//  CreateOrderForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


struct CreateOrderForm: View {
    
    @ObjectBinding var newOrder: Order
    
    var onCancel: () -> Void
    
    var onPlacedOrder: () -> Void
    
    
    var body: some View {
        OrderForm(order: newOrder)
            .navigationBarTitle("New Order", displayMode: .inline)
            .navigationBarItems(leading: cancelOrderNavItem, trailing: placeOrderNavItem)
    }
    
    
    var cancelOrderNavItem: some View {
        Button("Cancel", action: onCancel)
    }
    
    var placeOrderNavItem: some View {
        Button("Place Order", action: onPlacedOrder)
    }
}

#if DEBUG
struct PlaceOrderView_Previews : PreviewProvider {
    
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    
    static var previews: some View {
        CreateOrderForm(newOrder: order, onCancel: {}, onPlacedOrder: {})
    }
}
#endif
