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
            ForEach(orderDataSource.fetchController.fetchedObjects ?? []) { order in // source order
                // use data source's update context to view and modifer the order
                // also send didChange once update button tapped so that the row disable the button
                OrderRow(order: order.get(from: self.cudDataSource.updateContext), onUpdate: { order in
                    guard order.hasPersistentChangedValues else { return }
                    self.cudDataSource.saveUpdateContext()
                    order.didChange.send()
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
        
        let form = CreateOrderForm(
            newOrder: cudDataSource.newObject!,
            onCancel: cancelOrder,
            onPlacedOrder: placeOrder
        )
        
        return Modal(NavigationView { form }, onDismiss: cancelOrder)
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
