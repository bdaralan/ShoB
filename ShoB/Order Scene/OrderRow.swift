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
    
    var onSave: (Order) -> Void
    
    @State private var orderModel = OrderForm.Model()
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: orderDetailView) { // row content
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
    }

    
    // MARK: - Body Component
    
    var orderDetailView: some View {
        OrderDetailView(order: order, model: $orderModel, onSave: {
            self.onSave(self.order)
        })
        .onAppear { // assign the order to the model.
            print("rowContent.onAppear")
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
        OrderRow(order: order, onSave: { _ in })
    }
}
#endif
