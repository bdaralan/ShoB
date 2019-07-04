//
//  PlaceOrderView.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


struct PlaceOrderView: View {
    
    @ObjectBinding var newOrder: Order
    
    var onCancelled: () -> Void
    
    var onPlacedOrder: () -> Void
    
    
    var body: some View {
        NavigationView {
            OrderForm(order: newOrder)
                .navigationBarTitle("New Order", displayMode: .inline)
                .navigationBarItems(leading: cancelOrderNavItem, trailing: placeOrderNavItem)
        }
    }
    
    
    var cancelOrderNavItem: some View {
        Button("Cancel", action: onCancelled)
    }
    
    var placeOrderNavItem: some View {
        Button("Place Order", action: onPlacedOrder)
    }
}

#if DEBUG
struct PlaceOrderView_Previews : PreviewProvider {
    static var previews: some View {
        PlaceOrderView(newOrder: sampleOrders().first!, onCancelled: {}, onPlacedOrder: {})
    }
}
#endif
