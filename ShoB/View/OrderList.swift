//
//  OrderList.swift
//  ShoB
//
//  Created by Dara Beng on 6/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData

struct OrderList: View {
    
    @ObjectBinding var orderList: FetchedDataSource<Order> = {
        let dataSource = FetchedDataSource(context: CoreDataStack.current.mainContext, entity: Order.self)
        let request = dataSource.fetchController.fetchRequest
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(Order.discount), ascending: true)]
        dataSource.performFetch()
        return dataSource
    }()

    @State private var currentSegment = Segment.today
    
    @State private var segments = [Segment.today, .tomorrow, .past7Days]
    
    @State private var isPlacingOrder = false
    
    
    // MARK: - View
    
    var body: some View {
        List {
            // MARK: Segment Control
            SegmentedControl(selection: $currentSegment) {
                ForEach(segments.identified(by: \.self)) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            
            // MARK: Order Rows
            ForEach(orderList.fetchController.fetchedObjects ?? []) { order in
                OrderRow(order: order, onUpdated: { hasChanges in
                    guard hasChanges else { return }
                    order.managedObjectContext?.quickSave()
                })
            }
        }
        .navigationBarItems(trailing: placeOrderNavItem)
        .presentation(isPlacingOrder ? placeOrderForm : nil)
    }
    
    // Note: if color is not set, the button become disabled after pressed (beta 2)
    var placeOrderNavItem: some View {
        let presentPlaceOrderForm = { self.isPlacingOrder = true }
        let navIcon = { Image(systemName: "plus").imageScale(.large) }
        return Button(action: presentPlaceOrderForm, label: navIcon).accentColor(.accentColor)
    }
    
    /// Construct an order form.
    /// - Parameter order: The order to view or pass `nil` get a create mode form.
    var placeOrderForm: Modal {
        let childContext = CoreDataStack.current.mainContext.newChildContext()
        let newOrder = Order(context: childContext)
        newOrder.discount = Cent.random(in: 100...500)
        
        let dismiss = {
            self.isPlacingOrder = false
        }
        
        let placeOrder = {
            childContext.quickSave()
            childContext.parent?.quickSave()
            self.isPlacingOrder = false
        }
        
        let orderForm = OrderForm(order: newOrder, onCancel: dismiss, onCommit: placeOrder)
        
        return Modal(NavigationView { orderForm }, onDismiss: dismiss)
    }
}


extension OrderList {
    
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
        OrderList()
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
