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
    
    var onDelete: () -> Void
    
    var onOrderAgain: (Order) -> Void
    
    var isSaveEnabled: Bool {
        order.hasPersistentChangedValues && order.hasValidInputs()
    }
    
    @State private var showConfirmDeleteAlert = false
    
    
    // MARK: - Body
    
    var body: some View {
        OrderForm(
            model: $model,
            onDelete: { self.showConfirmDeleteAlert = true },
            onOrderAgain: { self.onOrderAgain(self.order) }
        )
            .navigationBarTitle("Order Details", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem(title: "Update"))
            .alert(isPresented: $showConfirmDeleteAlert, content: { deleteConfirmationAlert })
    }
}


// MARK: - Body Component

extension OrderDetailView {
    
    var deleteConfirmationAlert: Alert {
        deleteConfirmationAlert(
            title: "Delete Order",
            message: nil,
            action: onDelete
        )
    }
}


#if DEBUG
struct OrderDetailView_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    static var previews: some View {
        OrderDetailView(order: order, model: .constant(.init()), onSave: {}, onDelete: {}, onOrderAgain: { _ in })
    }
}
#endif
