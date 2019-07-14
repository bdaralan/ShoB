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
    
    @ObjectBinding var dataSource: CUDDataSource<Order>
    
    var onCancel: () -> Void
    
    var onPlacedOrder: () -> Void
    
    
    var body: some View {
        OrderForm(order: dataSource.newObject!)
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
    
    static let cud = CUDDataSource<Order>(context: CoreDataStack.current.mainContext)
    
    static var previews: some View {
        CreateOrderForm(dataSource: cud, onCancel: {}, onPlacedOrder: {})
    }
}
#endif
