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


/// A form used to view and edit order.
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
    @State private var showModalPresentationSheet = false
    
    /// A modal presentation sheet.
    ///
    /// The sheet can be set and used to present:
    /// - order item form
    /// - add or edit item form
    /// - customer selection list
    @State private var modalPresentationSheet = EmptyView().toAnyView()
    
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // MARK: Customer Section
            Section(header: Text.topSection("CUSTOMER")) {
                currentCustomerRow
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
                    self.modalPresentationSheet = self.addOrderItemForm.toAnyView()
                    self.showModalPresentationSheet = true
                }, label: {
                    HStack {
                        Text("Add Item")
                        Spacer()
                        Image(systemName: "plus.circle").imageScale(.large)
                    }
                })
                
                // MARK: Order Item List
                if model.order != nil {
                    ForEach(model.order!.orderItems.sorted(by: { $0.name < $1.name })) { item in
                        Button(action: {
                            self.editOrderItemModel = .init(item: item)
                            self.modalPresentationSheet = self.editOrderItemForm.toAnyView()
                            self.showModalPresentationSheet = true
                        }, label: {
                            self.orderItemRow(for: item)
                        })
                        .buttonStyle(PlainButtonStyle())
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
            isPresented: $showModalPresentationSheet,
            onDismiss: dismissOrderItemFormSheet,
            content: { self.modalPresentationSheet }
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
                        })
                        .buttonStyle(PlainButtonStyle())
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
            
            // send change to reload form's Update button's state
            order.objectWillChange.send()
            
            // create order item and add it to the order
            let newOrderItem = OrderItem(context: context)
            newOrderItem.order = order
            self.newOrderItemModel.assign(to: newOrderItem)
            
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
    
    var currentCustomerRow: some View {
        if let customer = model.order?.customer {
            return Button(action: showCustomerSelectionList, label: { CustomerRow.ContentView(customer: customer) })
                .buttonStyle(PlainButtonStyle())
                .toAnyView()
        } else {
            return Button(action: showCustomerSelectionList, label: { currentCustomerRowNone })
                .toAnyView()
        }
    }
    
    var currentCustomerRowNone: some View {
        HStack {
            Image.SFCustomer.profile
            Text("None")
            Spacer()
            Text("Select Customer")
        }
        .foregroundColor(.secondary)
    }
    
    var customerSelectionList: some View {
        NavigationView {
            List {
                ForEach(customerDataSource.fetchController.fetchedObjects ?? []) { customer in
                    self.customerSelectionRow(for: customer)
                }
            }
            .navigationBarTitle("Select Customer", displayMode: .inline)
            .navigationBarItems(leading: customerSelectionCancelNavItem, trailing: customerSelectionDeselectNavItem)
        }
    }
    
    var customerSelectionDeselectNavItem: some View {
        Button(action: { self.selectCustomer(nil) }) {
            Image(systemName: "person.crop.circle.badge.xmark").imageScale(.large)
        }
    }
    
    var customerSelectionCancelNavItem: some View {
        Button("Cancel", action: { self.showModalPresentationSheet = false })
    }
    
    func customerSelectionRow(for customer: Customer) -> some View {
        Button(action: { self.selectCustomer(customer) }) {
            HStack {
                CustomerRow.ContentView(customer: customer)
                if customer.objectID == self.model.order?.customer?.objectID {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func orderItemRow(for item: OrderItem) -> some View {
        HStack {
            Text("\(item.quantity) x \(item.name)")
            Spacer()
            Text(verbatim: "\(Currency(item.subtotal))")
            Image(systemName: "square.and.pencil")
                .imageScale(.large)
                .padding(.init(top: 0, leading: 16, bottom: 6, trailing: 0))
        }
    }
    
    
    // MARK: - Method
    
    /// Dismiss the presenting add or edit order form sheet and clean up as needed.
    func dismissOrderItemFormSheet() {
        // clean up if the sheet is editOrderItemForm, else it is addOrderItemForm or customerSelectionList
        if editOrderItemModel.orderItem != nil, let order = model.order {
            order.objectWillChange.send()
            
            // manually mark order as has changed if its item has changed
            // because hasPersistentChangedValues only check the object property
            // but not its array's object's property
            let hasOrderItemsChanged = order.orderItems.map({ $0.hasPersistentChangedValues }).contains(true)
            order.isMarkedValuesChanged = hasOrderItemsChanged
            
            // set orderItem to nil to avoid updating the item (safeguard)
            // the model is not set to .init() to prevent UI reloading while it is dismissing
            // because of @State
            editOrderItemModel.orderItem = nil
        }
        
        showModalPresentationSheet = false
    }
    
    /// Delete the current editing order item.
    func deleteOrderItemFromOrder() {
        guard let itemToDelete = editOrderItemModel.orderItem else { return }
        guard let context = itemToDelete.managedObjectContext else { return }
        context.delete(itemToDelete)
        dismissOrderItemFormSheet()
    }
    
    func selectCustomer(_ customer: Customer?) {
        if let customer = customer, let order = model.order, let context = order.managedObjectContext {
            order.customer = customer.get(from: context)
        } else {
            model.order?.customer = nil
        }
        showModalPresentationSheet = false
    }
    
    func showCustomerSelectionList() {
        modalPresentationSheet = customerSelectionList.toAnyView()
        showModalPresentationSheet = true
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
