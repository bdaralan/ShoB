//
//  PlaceOrderView.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


struct PlaceOrderView : View {
    
    @EnvironmentObject var orderingDataSource: OrderingDataSource
    
    var onCancelled: () -> Void
    
    var onPlacedOrder: () -> Void
    
    
    var body: some View {
        NavigationView {
            OrderForm(order: orderingDataSource.newOrder)
                .navigationBarTitle("New Order", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel", action: { self.cancelOrder() }),
                    trailing: Button("Place Order", action: { self.placeOrder() })
                )
        }
    }
    
    
    func cancelOrder() {
        print("PlaceOrderView cancelOrder")
        orderingDataSource.cancelPlacingNewOrder()
        onCancelled()
    }
    
    func placeOrder() {
        print("PlaceOrderView placeOrder")
        orderingDataSource.placeNewOrder()
        onPlacedOrder()
    }
}

#if DEBUG
struct PlaceOrderView_Previews : PreviewProvider {
    static var previews: some View {
        PlaceOrderView(onCancelled: {}, onPlacedOrder: {})
    }
}
#endif
