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

    @State private var currentSegment = Segment.today
    
    @State private var segments = [Segment.today, .tomorrow, .past7Days]
    
    /// A flag used to present or dismiss `placeOrderForm`.
    @State private var showPlaceOrderForm = false
    
    /// The model used to place new order.
    @State private var newOrderModel = OrderFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            // MARK: Segment Picker
            Picker("", selection: $currentSegment) {
                ForEach(segments, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
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
            isPresented: $showPlaceOrderForm,
            onDismiss: dismissPlaceOrderForm,
            content: { self.placeOrderForm }
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
            self.showPlaceOrderForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
    }
    
    /// Construct an order form.
    /// - Parameter order: The order to view or pass `nil` get a create mode form.
    var placeOrderForm: some View {
        NavigationView {
            CreateOrderForm(
                model: $newOrderModel,
                onCreate: saveNewOrder,
                onCancel: dismissPlaceOrderForm
            )
            .environmentObject(saleItemDataSource)
            .environmentObject(customerDataSource)
        }
    }
}


// MARK: - Method

extension OrderListView {
    
    /// Dismiss place order form.
    ///
    /// If the form was cancelled or dismissed, any changes to the data source's create context is discarded.
    func dismissPlaceOrderForm() {
        dataSource.cud.discardCreateContext()
        showPlaceOrderForm = false
    }
    
    /// Save the new order to the data source.
    func saveNewOrder() {
        dataSource.cud.saveCreateContext()
        showPlaceOrderForm = false
    }
    
    func updateOrder(_ order: Order) {
        order.objectWillChange.send()
        
        if order.hasPersistentChangedValues || order.isMarkedValuesChanged {
            order.isMarkedValuesChanged = false
            dataSource.cud.saveUpdateContext()
        } else {
            dataSource.cud.discardUpdateContext()
        }
    }
    
    func deleteOrder(_ order: Order) {
        print("deleteOrder")
        dataSource.cud.delete(order, saveContext: true)
        viewReloader.forceReload()
    }
    
    func placeOrderAgain(_ order: Order) {
        print("placeOrderAgain")
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
