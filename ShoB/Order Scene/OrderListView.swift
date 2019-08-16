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
    
    @EnvironmentObject var orderDataSource: OrderDataSource
    
    /// Used to display sale item list when create new order.
    @EnvironmentObject var saleItemDataSource: SaleItemDataSource
    
    @EnvironmentObject var customerDataSource: CustomerDataSource
    
    @ObservedObject private var model = OrderListViewModel()
    
    /// A flag used to present or dismiss `createOrderForm`.
    @State private var showCreateOrderForm = false
    
    /// The model used to create new order.
    @State private var newOrderModel = OrderFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section(header: segmentPicker) {
                ForEach(orderDataSource.fetchedResult.fetchedObjects ?? []) { order in
                    OrderRow(
                        order: self.orderDataSource.readObject(order),
                        onSave: self.updateOrder,
                        onDelete: self.deleteOrder,
                        onOrderAgain: self.placeOrderAgain
                    )
                }
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
            self.orderDataSource.discardNewObject()
            self.orderDataSource.prepareNewObject()
            self.newOrderModel = .init(order: self.orderDataSource.newObject!)
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
    
    var segmentPicker: some View {
        Picker("", selection: $model.currentSegment) {
            ForEach(model.segmentOptions, id: \.self) { segment in
                Text(segment.title).tag(segment)
                    // use fixedSize to fix the following outputs:
                    //
                    // clamping fail!
                    // proposed: _ProposedSize(width: Optional(0.0), height: Optional(0.0)) => (0.0, 197.5)
                    // clamped: (0.0, 21.5) => (0.0, 21.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical, 8)
        .onReceive(model.$currentSegment, perform: reloadList)
    }
}


// MARK: - Method

extension OrderListView {
    
    /// Dismiss create order form.
    ///
    /// If the form was cancelled or dismissed, any changes to the data source's create context is discarded.
    func dismissCreateOrderForm() {
        orderDataSource.discardCreateContext()
        showCreateOrderForm = false
    }
    
    /// Save the new order to the data source.
    func saveNewOrder() {
        guard newOrderModel.order!.hasValidInputs() else { return }
        orderDataSource.saveNewObject()
        showCreateOrderForm = false
    }
    
    /// Save changes.
    /// - Parameter order: The order to save.
    func updateOrder(_ order: Order) {
        self.orderDataSource.saveUpdateObject()
    }
    
    /// Delete order.
    /// - Parameter order: The order to delete.
    func deleteOrder(_ order: Order) {
        orderDataSource.delete(order, saveContext: true)
        viewReloader.forceReload()
    }
    
    /// Create a new order from an old order.
    /// - Parameter order: The old order.
    func placeOrderAgain(_ order: Order) {
        // prepare new object
        orderDataSource.discardNewObject()
        orderDataSource.prepareNewObject()
        let newOrder = orderDataSource.newObject!
        let oldOrder = order.get(from: orderDataSource.createContext)
        
        // copy neccessary values
        newOrder.discount = oldOrder.discount
        newOrder.note = oldOrder.note
        newOrder.customer = oldOrder.customer
        newOrder.store = oldOrder.store
        
        // copy order items
        order.orderItems.forEach {
            let copiedItem = OrderItem(context: orderDataSource.createContext)
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
        
        case .today:
            orderDataSource.performFetch(Order.requestDeliverToday())
        
        case .upcoming:
            let tomorrow = Date.startOfToday(addingDay: 1)
            orderDataSource.performFetch(Order.requestDeliver(from: tomorrow))
        
        case .pastDay(let day):
            orderDataSource.performFetch(Order.requestDeliver(fromPastDay: day))
        }
    }
}


// MARK: - Class Component

extension OrderListView {
    
    enum Segment: Hashable {
        case pastDay(Int)
        case today
        case upcoming
        
        var title: String {
            switch self {
            case .pastDay(let day): return "Past \(day) Days"
            case .today: return "Today"
            case .upcoming: return "Upcoming"
            }
        }
    }
}


#if DEBUG
struct OrderList_Previews : PreviewProvider {
    static var previews: some View {
        OrderListView()
    }
}
#endif
