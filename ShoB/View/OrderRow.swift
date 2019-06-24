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
    
    let context: NSManagedObjectContext
    
    let order: Order
    
    var onUpdated: (Bool) -> Void
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    init(order: Order, onUpdated: @escaping (Bool) -> Void) {
        self.context = order.managedObjectContext!.newChildContext()
        self.order = order.get(from: context)
        self.onUpdated = onUpdated
    }
    
    
    var body: some View {
        let orderForm = OrderForm(order: order, onCommit: {
            let hasChanges = self.order.hasPersistentChangedValues
            if hasChanges {
                self.context.quickSave()
            }
            self.onUpdated(hasChanges)
        }).onAppear {
            self.context.rollback()
        }
        
        let content = VStack(alignment: .leading) {
            Text("Order Date:\t \(formatter.string(from: order.orderDate))")
            Text("Delivery Date:\t \(formatter.string(from: order.deliveryDate))")
            if order.deliveredDate == nil {
                Text("Delivered:\t No")
            } else {
                Text("Delivery Date:\t \(formatter.string(from: order.deliveredDate!))")
            }
            Text("Discount: \(order.discount)")
            Text("Note: \(order.note)")
        }
        
        return NavigationButton(destination: orderForm, label: { content })
    }
}


#if DEBUG
struct OrderRow_Previews : PreviewProvider {
    static var previews: some View {
        OrderRow(order: Order(context: CoreDataStack.current.mainContext), onUpdated: { bool in })
    }
}
#endif
