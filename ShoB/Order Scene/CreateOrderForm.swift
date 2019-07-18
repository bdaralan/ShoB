//
//  CreateOrderForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


/// A form used to create new order.
struct CreateOrderForm: View {
    
    /// The model to create order.
    @Binding var model: OrderForm.Model
    
    /// Triggered when the new order is placed.
    var onPlaceOrder: () -> Void
    
    /// Triggered when cancelled to create a new order.
    var onCancel: () -> Void
    
    
    var body: some View {
        OrderForm(model: $model)
            .navigationBarTitle("New Order", displayMode: .inline)
            .navigationBarItems(leading: cancelOrderNavItem, trailing: placeOrderNavItem)
    }
    
    
    var cancelOrderNavItem: some View {
        Button("Cancel", action: onCancel)
    }
    
    var placeOrderNavItem: some View {
        Button("Place Order", action: onPlaceOrder)
            .font(Font.body.bold())
    }
}


#if DEBUG
struct PlaceOrderView_Previews : PreviewProvider {
    static let cud = CUDDataSource<Order>(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CreateOrderForm(model: .constant(.init()), onPlaceOrder: {}, onCancel: {})
    }
}
#endif
