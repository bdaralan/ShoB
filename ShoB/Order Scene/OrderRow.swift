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
    
    @ObjectBinding var order: Order
    
    var onUpdate: (Order) -> Void
    
    
    var body: some View {
        let orderDetailView = OrderDetailView(order: order, onUpdate: {
            self.onUpdate(self.order)
        })
        
        return NavigationLink(destination: orderDetailView, label: { rowContent })
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
}


fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()


#if DEBUG
struct OrderRow_Previews : PreviewProvider {
    static var previews: some View {
        OrderRow(order: Order(context: CoreDataStack.current.mainContext), onUpdate: { order in })
    }
}
#endif
