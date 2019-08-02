//
//  OrderDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays order's details.
struct OrderDetailView: View, EditableForm {
    
    @ObservedObject var order: Order
    
    /// The order to view or update.
    @Binding var model: OrderFormModel
    
    var onSave: () -> Void
    
    var onDelete: (Order) -> Void
    
    var onOrderAgain: (Order) -> Void
    
    
    // MARK: - Body
    
    var body: some View {
        OrderForm(model: $model, onDelete: onDelete, onOrderAgain: onOrderAgain)
            .navigationBarTitle("Order Details", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem(title: "Update", enable: order.hasPersistentChangedValues || order.isMarkedValuesChanged))
    }
}


#if DEBUG
struct OrderDetailView_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    static var previews: some View {
        OrderDetailView(order: order, model: .constant(.init()), onSave: {}, onDelete: { _ in }, onOrderAgain: { _ in })
    }
}
#endif
