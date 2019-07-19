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
    @Binding var model: OrderForm.Model
    
    /// Triggered when the order is updated.
    var onUpdate: () -> Void
    
    
    var body: some View {
        OrderForm(model: $model)
            .navigationBarTitle("Order Details", displayMode: .inline)
            .navigationBarItems(trailing: updateOrderNavItem)
    }
    
    
    var updateOrderNavItem: some View {
        Button("Update", action: onUpdate)
            .font(Font.body.bold())
//            .disabled(!model.order!.hasPersistentChangedValues)
    }
}

#if DEBUG
struct OrderDetailView_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    static var previews: some View {
        OrderDetailView(model: .constant(.init()), onUpdate: {})
    }
}
#endif
