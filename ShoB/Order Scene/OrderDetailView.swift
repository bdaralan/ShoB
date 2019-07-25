//
//  OrderDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct OrderDetailView: View, EditableForm {
    
    @ObjectBinding var order: Order
    
    /// The order to view or update.
    @Binding var model: OrderForm.Model
    
    var onSave: () -> Void
    
    
    // MARK: - Body
    
    var body: some View {
        OrderForm(model: $model)
            .navigationBarTitle("Order Details", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem)
    }
    
    
    // MARK: - Body Component
    
    var saveNavItem: some View {
        saveNavItem(title: "Update", enable: order.hasPersistentChangedValues || order.isMarkedValuesChanged)
    }
}

#if DEBUG
struct OrderDetailView_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    static var previews: some View {
        OrderDetailView(order: order, model: .constant(.init()), onSave: {})
    }
}
#endif
