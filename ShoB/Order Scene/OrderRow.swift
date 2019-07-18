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
    
    /// The source order.
    @ObjectBinding var sourceOrder: Order
    
    /// The data source that will update and save the order.
    @ObjectBinding var dataSource: CUDDataSource<Order>
    
    /// Triggered when the order is updated.
    var onUpdated: (() -> Void)?
    
    /// The order to be updated.
    ///
    /// This is the source order, but get from data source's update context.
    var orderToUpdate: Order {
        sourceOrder.get(from: dataSource.updateContext)
    }
    
    
    var body: some View {
        let orderDetailView = OrderDetailView(order: orderToUpdate, onUpdated: {
            self.dataSource.sourceContext.quickSave()
            self.onUpdated?()
        })
        
        return NavigationLink(destination: orderDetailView, label: { rowContent })
    }
    
    
    var rowContent: some View {
        VStack(alignment: .leading) {
            Text("Order Date:\t \(formatter.string(from: sourceOrder.orderDate))")
            
            if sourceOrder.deliveryDate == nil {
                Text("Deliver:\t No")
            } else {
                Text("Delivery Date:\t \(formatter.string(from: sourceOrder.deliveryDate!))")
            }
            
            
            if sourceOrder.deliveredDate == nil {
                Text("Delivered:\t No")
            } else {
                Text("Delivery Date:\t \(formatter.string(from: sourceOrder.deliveredDate!))")
            }
            
            Text("Discount: \(sourceOrder.discount)")
            
            Text("Note: \(sourceOrder.note)")
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
        OrderRow(sourceOrder: order, dataSource: cud, onUpdated: nil)
    }
}
#endif
