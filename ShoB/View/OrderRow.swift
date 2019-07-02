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
    
    let order: Order
    
    var onUpdate: (Order) -> Void
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    var body: some View {
        let orderForm = OrderForm(mode: .view(order), onCommit: { order in
            self.onUpdate(order)
        })
        
        let content = VStack(alignment: .leading) {
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
        
        return NavigationLink(destination: orderForm, label: { content })
    }
}


#if DEBUG
struct OrderRow_Previews : PreviewProvider {
    static var previews: some View {
        OrderRow(order: Order(context: CoreDataStack.current.mainContext), onUpdate: { order in })
    }
}
#endif
