//
//  OrderForm.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine
import CoreData


/// A form use to view and editing order.
struct OrderForm: View {
    
    @EnvironmentObject var customerDataSource: FetchedDataSource<Customer>
    
    @EnvironmentObject var saleItemDataSource: FetchedDataSource<SaleItem>
    
    /// Model used to create order.
    @Binding var model: Model
    
    /// Model used to create and add item to the order.
    @State private var newOrderItemModel = SaleItemForm.Model()
    
    /// Model used to edit order's item.
    @State private var editOrderItemModel = SaleItemForm.Model()
    
    /// Flag used to show order item form sheet, either add or edit item form.
    @State private var showOrderItemForm = false
    
    /// The order item form sheet, either add or edit item.
    @State private var sheetOrderItemForm = AnyView(EmptyView())
    
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // MARK: Customer Section
            Section(header: Text.topSection("CUSTOMER")) {
                Picker("Customer", selection: $model.customerURI) {
                    ForEach([Model.customerURINone] + customerDataSource.fetchedObjectURIs(), id: \.self) { uri in
                        self.customerPickerRow(forURI: uri)
                    }
                }
            }
            
            // MARK: Date Section
            Section(header: Text("ORDER DETAILS")) {
                DatePicker("Order Date", selection: $model.orderDate)

                Toggle("Delivery", isOn: $model.isDelivering)
                if model.isDelivering {
                    DatePicker("Delivery Date", selection: $model.deliveryDate)
                }

                Toggle("Delivered", isOn: $model.isDelivered)
                if model.isDelivered {
                    DatePicker("Delivered Date", selection: $model.deliveredDate)
                }
            }
            
            // MARK: Total Section
            Section(header: Text("TOTAL & DISCOUNT")) {
                HStack {
                    Text("Total").bold()
                    Spacer()
                    Text(model.totalAfterDiscount).bold()
                }
                
                HStack {
                    Text("Before Discount")
                    Spacer()
                    Text(model.totalBeforeDiscount)
                }
                
                HStack {
                    Text("Discount")
                    TextField("$0.00", text: $model.discount)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            // MARK: Items Section
            Section(header: Text("ORDER ITEMS")) {
                
                // MARK: Add Button
                Button(action: {
                    self.newOrderItemModel = .init()
                    self.sheetOrderItemForm = AnyView(self.addOrderItemForm)
                    self.showOrderItemForm = true
                }, label: {
                    HStack {
                        Text("Add Item")
                        Spacer()
                        Image(systemName: "plus.circle").imageScale(.large)
                    }
                })
                
                // MARK: Order Item List
                if model.order != nil {
                    ForEach(model.order!.orderItems.sorted(by: { $0.name < $1.name }), id: \.self) { item in
                        Button(action: {
                            self.editOrderItemModel = .init(item: item)
                            self.sheetOrderItemForm = AnyView(self.editOrderItemForm)
                            self.showOrderItemForm = true
                        }, label: {
                            HStack {
                                Text("\(item.name) | \(item.subtotal)")
                                Spacer()
                                Image(systemName: "square.and.pencil").imageScale(.large)
                            }
                            .accentColor(.primary)
                        })
                    }
                }
            }

            // MARK: Note Section
            Section(header: Text("NOTE")) {
                VStack {
                    TextField(". . .", text: $model.note)
                        .lineLimit(nil)
                        .padding([.top, .bottom])
                    Spacer()
                }
                .frame(minHeight: 200)
            }
        }
        .sheet(
            isPresented: $showOrderItemForm,
            onDismiss: dismissOrderItemFormSheet,
            content: { self.sheetOrderItemForm }
        )
        
    }
    
    
    // MARK: - Body Component
    
    var addOrderItemForm: some View {
        NavigationView {
            Form {
                // Input Section
                Section(header: Text.topSection("ORDER ITEM")) {
                    SaleItemForm.BodyView(model: self.$newOrderItemModel, mode: .orderItem)
                }
                
                // Sale Item List Section
                Section(header: Text("ALL SALE ITEMS")) {
                    ForEach(saleItemDataSource.fetchController.fetchedObjects ?? []) { item in
                        Button(action: {
                            self.newOrderItemModel = .init(item: item, keepReference: false)
                        }, label: {
                            HStack {
                                Text("\(item.name)")
                                Spacer()
                                Text(verbatim: "\(Currency(item.price))")
                            }
                            .accentColor(.primary)
                        })
                    }
                }
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            .navigationBarItems(leading: addOrderItemFormCancelNavItem, trailing: addOrderItemFormAddNavItem)
        }
    }
    
    var addOrderItemFormAddNavItem: some View {
        Button("Add", action: {
            guard let order = self.model.order, let context = order.managedObjectContext else { return }
            
            // create order item and add it to the order
            let newOrderItem = OrderItem(context: context)
            newOrderItem.order = order
            self.newOrderItemModel.assign(to: newOrderItem)
            
            // send change to reload form's Update button's state
            order.willChange.send()
            
            self.dismissOrderItemFormSheet()
        })
    }
    
    var addOrderItemFormCancelNavItem: some View {
        Button("Cancel", action: dismissOrderItemFormSheet)
    }
    
    var editOrderItemForm: some View {
        NavigationView {
            Form {
                Section {
                    SaleItemForm.BodyView(model: $editOrderItemModel, mode: .orderItem)
                }
                Section {
                    Button(action: deleteOrderItemFromOrder) {
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Remove From Order").foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarTitle("Edit Item", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done", action: dismissOrderItemFormSheet))
        }
    }
    
    func customerPickerRow(forURI uri: URL) -> some View {
        if let customer = model.customer(forURI: uri) {
            return Text("\(customer.identity)")
                .tag(uri)
                .foregroundColor(.primary)
        }
        
        return Text("None")
            .tag(Model.customerURINone)
            .foregroundColor(.secondary)
    }
    
    
    // MARK: - Method
    
    /// Dismiss the presenting add or edit order form sheet and clean up as needed.
    func dismissOrderItemFormSheet() {
        // clean up if the sheet is editOrderItemForm, else it is addOrderItemForm
        if editOrderItemModel.orderItem != nil, let order = model.order {
            // manually mark order as has changed if its item has changed
            // because hasPersistentChangedValues only check the object property
            // but not its array's object's property
            let hasOrderItemsChanged = order.orderItems.map({ $0.hasPersistentChangedValues }).contains(true)
            order.isMarkedValuesChanged = hasOrderItemsChanged
            order.willChange.send()
            
            // set orderItem to nil to avoid updating the item (safeguard)
            // the model is not set to .init() to prevent UI reloading while it is dismissing
            // because of @State
            editOrderItemModel.orderItem = nil
        }
        showOrderItemForm = false
    }
    
    /// Delete the current editing order item.
    func deleteOrderItemFromOrder() {
        guard let itemToDelete = editOrderItemModel.orderItem else { return }
        guard let context = itemToDelete.managedObjectContext else { return }
        context.delete(itemToDelete)
        dismissOrderItemFormSheet()
    }
}


#if DEBUG
struct OrderForm_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    static var previews: some View {
        OrderForm(model: .constant(.init()))
    }
}
#endif
