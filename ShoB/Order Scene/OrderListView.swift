//
//  OrderListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays store's orders in a list.
struct OrderListView: View {
    
    @EnvironmentObject var dataSource: FetchedDataSource<Order>
    
    /// Used to display sale item list when create new order.
    @EnvironmentObject var saleItemDataSource: FetchedDataSource<SaleItem>
    
    @EnvironmentObject var customerDataSource: FetchedDataSource<Customer>
    
    @ObservedObject private var model = OrderListViewModel()
    
    /// A flag used to present or dismiss `createOrderForm`.
    @State private var showCreateOrderForm = false
    
    /// The model used to create new order.
    @State private var newOrderModel = OrderFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    
    // MARK: - Body
    
    var body: some View {
        
        List {
            // MARK: Segment Picker
            Picker("", selection: $model.currentSegment) {
                ForEach(model.segmentOptions, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onReceive(model.$currentSegment, perform: reloadList)
            
            
            // MARK: Order Rows
            ForEach(dataSource.fetchController.fetchedObjects ?? [], id: \.self) { order in
                OrderRow(
                    order: order.get(from: self.dataSource.cud.updateContext),
                    onSave: self.updateOrder,
                    onDelete: self.deleteOrder,
                    onOrderAgain: self.placeOrderAgain
                )
            }
        }
        .navigationBarItems(trailing: placeNewOrderNavItem)
        .sheet(
            isPresented: $showCreateOrderForm,
            onDismiss: dismissCreateOrderForm,
            content: { self.createOrderForm }
        )
    }
}


// MARK: - Body Component

extension OrderListView {
    
    var placeNewOrderNavItem: some View {
        Button(action: {
            // discard and create a new order object for the form
            self.dataSource.cud.discardNewObject()
            self.dataSource.cud.prepareNewObject()
            self.newOrderModel = .init(order: self.dataSource.cud.newObject!)
            self.showCreateOrderForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
    }
    
    /// Form form creating new order.
    var createOrderForm: some View {
        NavigationView {
            CreateOrderForm(
                model: $newOrderModel,
                onCreate: saveNewOrder,
                onCancel: dismissCreateOrderForm
            )
            .environmentObject(saleItemDataSource)
            .environmentObject(customerDataSource)
        }
    }
}


// MARK: - Method

extension OrderListView {
    
    /// Dismiss create order form.
    ///
    /// If the form was cancelled or dismissed, any changes to the data source's create context is discarded.
    func dismissCreateOrderForm() {
        dataSource.cud.discardCreateContext()
        showCreateOrderForm = false
    }
    
    /// Save the new order to the data source.
    func saveNewOrder() {
        dataSource.cud.saveCreateContext()
        showCreateOrderForm = false
    }
    
    /// Save changes.
    /// - Parameter order: The order to save.
    func updateOrder(_ order: Order) {
        order.objectWillChange.send()
        
        if order.hasPersistentChangedValues || order.isMarkedValuesChanged {
            order.isMarkedValuesChanged = false
            dataSource.cud.saveUpdateContext()
            viewReloader.forceReload()
        } else {
            dataSource.cud.discardUpdateContext()
        }
    }
    
    /// Delete order.
    /// - Parameter order: The order to delete.
    func deleteOrder(_ order: Order) {
        dataSource.cud.delete(order, saveContext: true)
        viewReloader.forceReload()
    }
    
    /// Create a new order from an old order.
    /// - Parameter order: The old order.
    func placeOrderAgain(_ order: Order) {
        let oldOrder = order.get(from: dataSource.cud.createContext)
        
        // prepare new object
        dataSource.cud.discardNewObject()
        dataSource.cud.prepareNewObject()
        let newOrder = dataSource.cud.newObject!
        
        // copy neccessary values
        newOrder.discount = oldOrder.discount
        newOrder.note = oldOrder.note
        newOrder.customer = oldOrder.customer
        newOrder.store = oldOrder.store
        
        // copy order items
        order.orderItems.forEach {
            let copiedItem = OrderItem(context: dataSource.cud.createContext)
            copiedItem.name = $0.name
            copiedItem.price = $0.price
            copiedItem.quantity = $0.quantity
            copiedItem.order = newOrder
        }
        
        // show the form
        newOrderModel = .init(order: newOrder)
        showCreateOrderForm = true
    }
    
    func reloadList(for segment: Segment) {
        switch segment {
        case .today: dataSource.performFetch(Order.requestDeliverToday())
        case .tomorrow: dataSource.performFetch(Order.requestDeliverTomorrow())
        case .past7Days: dataSource.performFetch(Order.requestDeliveredPast7Days())
        case .all: break
        }
    }
}


// MARK: - Class Component

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
