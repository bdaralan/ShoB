//
//  OrderListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData

struct OrderListView: View {
    
    @EnvironmentObject var cudDataSource: CUDDataSource<Order>
    
    @EnvironmentObject var orderDataSource: FetchedDataSource<Order>

    @State private var currentSegment = Segment.today
    
    @State private var segments = [Segment.today, .tomorrow, .past7Days]
    
    /// A flag used to present or dismiss `placeOrderForm`.
    @State private var isPlacingOrder = false
    
    
    var body: some View {
        List {
            // MARK: Segment Control
            SegmentedControl(selection: $currentSegment) {
                ForEach(segments.identified(by: \.self)) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            
            // MARK: Order Rows
            ForEach(orderDataSource.fetchController.fetchedObjects ?? []) { order in
                OrderRow(order: order.get(from: self.cudDataSource.updateContext), onUpdate: { order in
                    self.cudDataSource.updateObject(order)
                })
            }
        }
        .navigationBarItems(trailing: placeNewOrderNavItem)
        .presentation(isPlacingOrder ? placeOrderForm : nil)
    }
    
    
    var placeNewOrderNavItem: some View {
        Button(action: {
            self.isPlacingOrder = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        }).accentColor(.accentColor)
    }
    
    /// Construct an order form.
    /// - Parameter order: The order to view or pass `nil` get a create mode form.
    var placeOrderForm: Modal {
        let cancelOrder = {
            self.cudDataSource.discardNewObject()
            self.isPlacingOrder = false
        }
        
        let placeOrder = {
            self.cudDataSource.saveNewObject()
            self.isPlacingOrder = false
        }
        
        let placeOrderView = PlaceOrderView(
            newOrder: cudDataSource.newObject,
            onCancelled: cancelOrder,
            onPlacedOrder: placeOrder
        )
        
        return Modal(placeOrderView, onDismiss: cancelOrder)
    }
}


extension OrderListView {
    
    enum Segment: String {
        case today = "Today"
        case tomorrow = "Tomorrow"
        case past7Days = "Past 7 Days"
        case all = "All"
    }
}


#if DEBUG
struct OrderList_Previews : PreviewProvider {
    static var previews: some View {
        OrderListView()
    }
}
#endif


func sampleOrders() -> [Order] {
    let context = CoreDataStack.current.mainContext
    var orders = [Order]()
    for i in 1...30 {
        let order = Order(context: context)
        order.discount = Cent(i * 10)
        orders.append(order)
    }
    return orders
}
