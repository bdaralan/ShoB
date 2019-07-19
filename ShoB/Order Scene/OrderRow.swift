//
//  OrderRow.swift
//  ShoB
//
//  Created by Dara Beng on 6/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


struct OrderRow: View {
    
    /// The order to view or update.
    @ObjectBinding var order: Order
    
    /// Triggered when the order is updated.
    var onUpdate: (OrderForm.Model) -> Void
    
    @State private var orderModel = OrderForm.Model()
    
    
    var body: some View {
        NavigationLink(destination: orderDetailView, label: { rowContent })
    }
    
    
    var rowContent: some View {
        VStack(alignment: .leading) {
            Text("Order Date:\t \(formatter.string(from: order.orderDate))")
            
            if order.deliveryDate == nil {
                Text("Deliver:\t No")
            } else {
                Text("Delivery Date:\t \(formatter.string(from: order.deliveryDate!))")
            }
            
            
            if order.deliveredDate == nil {
                Text("Delivered:\t No")
            } else {
                Text("Delivery Date:\t \(formatter.string(from: order.deliveredDate!))")
            }
            
            Text("Discount: \(order.discount)")
            
            Text("Note: \(order.note)")
        }
    }
    
    var orderDetailView: some View {
        OrderDetailView(model: $orderModel, onUpdate: {
            self.onUpdate(self.orderModel)
        })
        .onAppear { // assign the order to the model.
            // DEVELOPER NOTE:
            // Do the assignment here for now until finding a better place for the assignment
            self.orderModel = .init(order: self.order)
        }
    }
}


fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()


#if DEBUG
struct OrderRow_Previews : PreviewProvider {
    static let cud = CUDDataSource<Order>(context: CoreDataStack.current.mainContext)
    static let order = Order(context: cud.sourceContext)
    static var previews: some View {
        OrderRow(order: order, onUpdate: { _ in })
    }
}
#endif
