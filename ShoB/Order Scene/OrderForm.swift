//
//  OrderForm.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A form used to view and edit order.
struct OrderForm: View {
    
    @EnvironmentObject var customerDataSource: FetchedDataSource<Customer>
    
    @EnvironmentObject var saleItemDataSource: FetchedDataSource<SaleItem>
    
    /// Model used to create order.
    @Binding var model: OrderFormModel
    
    var onDelete: ((Order) -> Void)?
    
    var onOrderAgain: ((Order) -> Void)?
    
    /// Model used to create and add item to the order.
    @State private var newOrderItemModel = SaleItemFormModel()
    
    /// Model used to edit order's item.
    @State private var editOrderItemModel = SaleItemFormModel()
    
    /// Flag used to show order item form sheet, either add or edit item form.
    @State private var showModalPresentationSheet = false
    
    /// A modal presentation sheet.
    ///
    /// The sheet can be set and used to present:
    /// - order item form
    /// - add or edit item form
    /// - customer selection list
    @State private var modalPresentationSheet = AnyView.emptyView
    
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // MARK: Customer Section
            Section(header: Text.topSection("CUSTOMER")) {
                customerRow(for: model.order?.customer)
            }
            
            // MARK: Date Section
            Section(header: Text("ORDER DETAILS")) {
                DatePicker("Order Date", selection: $model.orderDate)
                DatePicker("Deliver Date", selection: $model.deliverDate)

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
            
            // MARK: Order Items Section
            Section(header: Text("ORDER ITEMS")) {
                
                // Add Item Button
                Button(action: showAddOrderItemForm) {
                    HStack {
                        Text("Add Item")
                        Spacer()
                        Image(systemName: "plus.circle").imageScale(.large)
                    }
                }
                
                // Order Item List
                ForEach(model.order?.orderItems.sorted(by: { $0.name < $1.name }) ?? []) { item in
                    Button(action: { self.showEditOrderItemForm(with: item) }) {
                        self.orderItemRow(for: item)
                    }
                    .buttonStyle(PlainButtonStyle())
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
            
            // MARK: Action Section
            Section {
                deleteOrderButtonRow
                orderAgainButtonRow
            }
        }
        .sheet(
            isPresented: $showModalPresentationSheet,
            onDismiss: dismissPresentationSheet,
            content: { self.modalPresentationSheet }
        )
    }
}


// MARK: - Form Row

extension OrderForm {
    
    /// Customer row displaying selected customer
    func customerRow(for customer: Customer?) -> some View {
        if let customer = customer {
            return Button(action: showCustomerSelectionView) {
                CustomerRowContentView(customer: customer)
            }
            .buttonStyle(PlainButtonStyle())
            .toAnyView()
            
        } else { // no customer selected
            return Button(action: showCustomerSelectionView) {
                HStack {
                    Image.SFCustomer.profile
                    Text("None")
                    Spacer()
                    Text("Select Customer")
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .toAnyView()
        }
    }
    
    /// Order's order item row.
    /// - Parameter item: Order item to display.
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
    
    /// Delete order button.
    var deleteOrderButtonRow: some View {
        guard let onDelete = onDelete, let order = model.order else { return AnyView.emptyView }
        return Button("Delete", action: { onDelete(order) })
            .buttonStyle(CenterButtonStyle(.destructive))
            .toAnyView()
    }
    
    /// Order again button.
    var orderAgainButtonRow: some View {
        guard let onOrderAgain = onOrderAgain, let order = model.order else { return AnyView.emptyView }
        return Button("Order Again", action: { onOrderAgain(order) })
            .buttonStyle(CenterButtonStyle(.normal))
            .toAnyView()
    }
}


// MARK: - Add Order Item Form

extension OrderForm {
    
    /// A form used to add order item to the order.
    var addOrderItemForm: some View {
        NavigationView {
            AddOrderItemForm(
                orderItemModel: $newOrderItemModel,
                saleItems: saleItemDataSource.fetchController.fetchedObjects ?? []
            )
                .navigationBarTitle("Add Item", displayMode: .inline)
                .navigationBarItems(leading: addOrderItemFormCancelNavItem, trailing: addOrderItemFormAddNavItem)
        }
    }
    
    /// Add navigation item for `addOrderItemForm`.
    var addOrderItemFormAddNavItem: some View {
        Button("Add", action: {
            guard let order = self.model.order, let context = order.managedObjectContext else { return }
            
            // send change to reload form's Update button's state
            order.objectWillChange.send()
            
            // create order item and add it to the order
            let newOrderItem = OrderItem(context: context)
            newOrderItem.order = order
            self.newOrderItemModel.assign(to: newOrderItem)
            
            self.dismissPresentationSheet()
        })
    }
    
    /// Cancel navigation item for `addOrderItemForm`.
    var addOrderItemFormCancelNavItem: some View {
        Button("Cancel", action: dismissPresentationSheet)
    }
}


// MARK: - Edit Order Item Form

extension OrderForm {
    
    /// A form used to edit order's item.
    var editOrderItemForm: some View {
        NavigationView {
            EditOrderItemForm(orderItemModel: $editOrderItemModel, onDelete: deleteEditingOrderItem)
                .navigationBarTitle("Edit Item", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done", action: dismissPresentationSheet))
        }
    }
    
    /// Delete the current editing order's item.
    func deleteEditingOrderItem() {
        guard let itemToDelete = editOrderItemModel.orderItem else { return }
        guard let context = itemToDelete.managedObjectContext else { return }
        context.delete(itemToDelete)
        dismissPresentationSheet()
    }
}


// MARK: - Customer Selection List View

extension OrderForm {
    
    /// A list view displaying all customers for user to select.
    var customerSelectionView: some View {
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
    
    /// Cancel nav item for `customerSelectionView`.
    var customerSelectionDeselectNavItem: some View {
        Button(action: { self.selectCustomer(nil) }) {
            Image(systemName: "person.crop.circle.badge.xmark").imageScale(.large)
        }
    }
    
    /// Deselect customer nav item for `customerSelectionView`.
    var customerSelectionCancelNavItem: some View {
        Button("Cancel", action: { self.showModalPresentationSheet = false })
    }
    
    /// Customer row for `customerSelectionView`.
    /// - Parameter customer: The customer to display.
    func customerSelectionRow(for customer: Customer) -> some View {
        Button(action: { self.selectCustomer(customer) }) {
            HStack {
                CustomerRowContentView(customer: customer)
                if customer.objectID == self.model.order?.customer?.objectID {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// Assign a customer to the order or `nil` for no customer.
    /// - Parameter customer: The customer to assign or `nil`.
    func selectCustomer(_ customer: Customer?) {
        if let customer = customer, let context = model.order?.managedObjectContext {
            model.order?.customer = customer.get(from: context)
        } else {
            model.order?.customer = nil
        }
        showModalPresentationSheet = false
    }
}


// MARK: - Method

extension OrderForm {
    
    /// Dismiss the presenting add or edit order form sheet and clean up as needed.
    func dismissPresentationSheet() {
        // for add-order-item form or customer-selection list, just dismiss
        // for edit-order-item form, do some clean up and reload
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
    
    /// Present `customerSelectionView` sheet.
    func showCustomerSelectionView() {
        modalPresentationSheet = customerSelectionView.toAnyView()
        showModalPresentationSheet = true
    }
    
    /// Present `editOrderItemForm` sheet.
    func showEditOrderItemForm(with item: OrderItem) {
        editOrderItemModel = .init(orderItem: item)
        modalPresentationSheet = editOrderItemForm.toAnyView()
        showModalPresentationSheet = true
    }
    
    /// Present `addOrderItemForm` sheet.
    func showAddOrderItemForm() {
        self.newOrderItemModel = .init()
        self.modalPresentationSheet = self.addOrderItemForm.toAnyView()
        self.showModalPresentationSheet = true
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
