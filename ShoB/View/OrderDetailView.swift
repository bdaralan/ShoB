//
//  OrderDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct OrderDetailView : View {
    
    @ObjectBinding var order: Order
    
    var onUpdate: () -> Void
    
    
    var body: some View {
        OrderForm()
            .environmentObject(order)
            .navigationBarItems(trailing: updateNavItem)
    }
    
    
    var updateNavItem: some View {
        Button("Update", action: onUpdate)
            .font(Font.body.bold())
            .disabled(!order.hasPersistentChangedValues)
    }
}

#if DEBUG
struct OrderDetailView_Previews : PreviewProvider {
    static var previews: some View {
        OrderDetailView(order: sampleOrders().first!, onUpdate: {})
    }
}
#endif
