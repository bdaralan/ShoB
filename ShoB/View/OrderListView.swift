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
    
    @EnvironmentObject var orderingDataSource: OrderingDataSource
    
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
                OrderRow(order: order.get(from: self.orderingDataSource.viewOrderContext), onUpdate: { order in
                    self.orderingDataSource.updateOrder(order)
                })
            }
        }
        .navigationBarItems(trailing: placeNewOrderNavItem)
        .presentation(isPlacingOrder ? placeOrderForm : nil)
    }
    
    
    /// Construct an order form.
    /// - Parameter order: The order to view or pass `nil` get a create mode form.
    var placeOrderForm: Modal {
        let dismiss = { self.isPlacingOrder = false }
        let placeOrderView = PlaceOrderView(onCancelled: dismiss, onPlacedOrder: dismiss).environmentObject(orderingDataSource)
        return Modal(placeOrderView, onDismiss: dismiss)
    }
    
    // Note: if color is not set, the button become disabled after pressed (beta 2)
    var placeNewOrderNavItem: some View {
        let presentPlaceOrderForm = { self.isPlacingOrder = true }
        let navIcon = { Image(systemName: "plus").imageScale(.large) }
        return Button(action: presentPlaceOrderForm, label: navIcon).accentColor(.accentColor)
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
