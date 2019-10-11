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
    
    @State private var showCreateOrderFailedAlert = false
    
    /// The model used to create new order.
    @State private var newOrderModel = OrderFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            segmentPicker
            if model.currentSegment == .today {
                listRows(for: orderDataSource.fetchedResult.fetchedObjects ?? [])
            } else { // for upcoming and past days
                listSectionedRows
            }
        }
        .navigationBarItems(trailing: placeNewOrderNavItem)
        .sheet(isPresented: $showCreateOrderForm, onDismiss: dismissCreateOrderForm, content: { self.createOrderForm })
        .alert(isPresented: $showCreateOrderFailedAlert, content: { .createObjectWithoutCurrentStore(object: "Order") })
        .onAppear(perform: setupView)
    }
}


// MARK: - Body Component

extension OrderListView {
    
    var placeNewOrderNavItem: some View {
        Button(action: beginCreateNewOrder) {
            Image(systemName: "plus").imageScale(.large)
        }
    }
    
    /// Form form creating new order.
    var createOrderForm: some View {
        NavigationView {
            OrderForm(
                model: $newOrderModel,
                onCreate: saveNewOrder,
                onCancel: dismissCreateOrderForm,
                enableCreate: newOrderModel.order!.isValid()
            )
                .environmentObject(saleItemDataSource)
                .environmentObject(customerDataSource)
                .navigationBarTitle("New Order", displayMode: .inline)
        }
    }
    
    var segmentPicker: some View {
        Picker("", selection: $model.currentSegment) {
            ForEach(model.segmentOptions, id: \.self) { segment in
                Text(segment.title).tag(segment)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical, 8)
        .onReceive(model.$currentSegment, perform: reloadList)
    }
    
    /// A list of order rows grouped into sections.
    /// - Note: Use with upcoming and past segment.
    var listSectionedRows: some View {
        let fetchedResult = orderDataSource.fetchedResult
        return ForEach(0..<(fetchedResult.sections!.count), id: \.self) { sectionIndex in
            Section(header: Text(self.sectionTitle(forDate: fetchedResult.sections![sectionIndex].name))) {
                self.listRows(for: fetchedResult.sections![sectionIndex].objects as! [Order])
            }
        }
    }
    
    /// A list of order rows.
    /// - Parameter orders: The orders to display
    func listRows(for orders: [Order]) -> some View {
        ForEach(orders, id: \.self) { order in
            OrderRow(
                order: self.orderDataSource.readObject(order),
                onDeleted: self.viewReloader.forceReload,
                onOrderAgain: self.placeOrderAgain
            )
        }
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
    
    func beginCreateNewOrder() {
        if let store = Store.current(from: orderDataSource.createContext) {
            // discard and prepare a new order object for the form
            orderDataSource.discardNewObject()
            orderDataSource.prepareNewObject()
            orderDataSource.newObject!.store = store
            newOrderModel = .init(order: orderDataSource.newObject!)
            showCreateOrderForm = true
        } else {
            showCreateOrderFailedAlert = true
        }
    }
    
    /// Save the new order to the data source.
    func saveNewOrder() {
        let result = orderDataSource.saveNewObject()
        switch result {
        case .saved: showCreateOrderForm = false
        case .failed: break // TODO: add alert
        case .unchanged: break
        }
    }
    
    /// Create a new order from an old order.
    /// - Parameter order: The old order.
    func placeOrderAgain(_ order: Order) {
        // prepare new object
        orderDataSource.discardNewObject()
        orderDataSource.prepareNewObject()
        
        let newOrder = orderDataSource.newObject!
        let oldOrder = order.get(from: orderDataSource.createContext)
        
        // copy necessary values
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
        guard let storeID = AppCache.currentStoreUniqueID else {
            orderDataSource.performFetch(Order.requestNoObject())
            return
        }
        
        switch segment {
        case .today:
            orderDataSource.setFetchResultSectionKeyPath(nil)
            orderDataSource.performFetch(Order.requestDeliverToday(storeID: storeID))
        
        case .upcoming:
            let tomorrow = Date.startOfToday(addingDay: 1)
            orderDataSource.setFetchResultSectionKeyPath(#keyPath(Order.deliverDateSection))
            orderDataSource.performFetch(Order.requestDeliver(from: tomorrow, storeID: storeID))
        
        case .pastDay(let day):
            orderDataSource.setFetchResultSectionKeyPath(#keyPath(Order.deliverDateSection))
            orderDataSource.performFetch(Order.requestDeliver(fromPastDay: day, storeID: storeID))
        }
    }
    
    func setupView() {
        fetchData()
    }
    
    func fetchData() {
        if let storeID = AppCache.currentStoreUniqueID {
            saleItemDataSource.performFetch(SaleItem.requestObjects(storeID: storeID))
            customerDataSource.performFetch(Customer.requestObjects(storeID: storeID))
        } else {
            saleItemDataSource.performFetch(SaleItem.requestNoObject())
            customerDataSource.performFetch(Customer.requestNoObject())
        }
        viewReloader.forceReload()
    }
    
    /// Format order row section title for upcoming and past days.
    /// - Parameter fromDate: The order's deliver date section string.
    func sectionTitle(forDate dateString: String) -> String {
        guard let date = Order.deliverDateSectionFormatter.date(from: dateString) else { return "???" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
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


struct OrderList_Previews : PreviewProvider {
    static var previews: some View {
        OrderListView()
    }
}
