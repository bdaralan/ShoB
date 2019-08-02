//
//  CreateOrderForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A form used to create new order.
struct CreateOrderForm: View, CreatableForm {
    
    /// The model to create order.
    @Binding var model: OrderFormModel
    
    /// Triggered when the new order is placed.
    var onCreate: () -> Void
    
    /// Triggered when cancelled to create a new order.
    var onCancel: () -> Void
    
    
    // MARK: - Body
    
    var body: some View {
        OrderForm(model: $model)
            .navigationBarTitle("New Order", displayMode: .inline)
            .navigationBarItems(leading: cancelNavItem(), trailing: createNavItem(title: "Place Order"))
    }
}


#if DEBUG
struct PlaceOrderView_Previews : PreviewProvider {
    static let cud = CUDDataSource<Order>(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CreateOrderForm(model: .constant(.init()), onCreate: {}, onCancel: {})
    }
}
#endif
