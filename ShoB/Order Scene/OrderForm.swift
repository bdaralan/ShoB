//
//  OrderForm.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A form used to view and edit order.
struct OrderForm: View, MultiPurposeForm {
    
    @EnvironmentObject var customerDataSource: CustomerDataSource
    
    @EnvironmentObject var saleItemDataSource: SaleItemDataSource
    
    /// Model used to create order.
    @Binding var model: OrderFormModel
    
    var onCreate: (() -> Void)?
    
    var onUpdate: (() -> Void)?
    
    var onCancel: (() -> Void)?
    
    var enableCreate: Bool?
    
    var enableUpdate: Bool?
    
    var rowActions: [MultiPurposeFormRowAction] = []
    
    /// Model used to create and add item to the order.
    @State private var newOrderItemModel = SaleItemFormModel()
    
    /// Model used to edit order's item.
    @State private var editOrderItemModel = SaleItemFormModel()
    
    /// Flag used to show `modalPresentationSheet`.
    @State private var showModalPresentationSheet = false
    
    /// A modal presentation sheet.
    ///
    /// The sheet can be set and used to present:
    /// - add or edit order item form
    /// - customer selection list
    @State private var modalPresentationSheet = AnyView.emptyView
    
    
    // MARK: - Body
    
    var body: some View {
        let form = Form {
            // MARK: Customer Section
            Section(header: Text.topSection("CUSTOMER")) {
                customerRow(for: model.order?.customer)
            }
            
            // MARK: Date Section
            Section(header: Text("ORDER DETAILS")) {
                DatePicker(selection: $model.orderDate) {
                    Image.SFOrder.orderDate
                    Text("Order Date")
                }
                
                DatePicker(selection: $model.deliverDate) {
                    Image.SFOrder.deliverDate
                    Text("Deliver Date")
                }

                Toggle(isOn: $model.isDelivered) {
                    Image.SFOrder.delivered
                    Text("Delivered")
                }
                
                if model.isDelivered {
                    DatePicker(selection: $model.deliveredDate) {
                        Image.SFOrder.delivered.foregroundColor(.green)
                        Text("Delivered Date")
                    }
                }
            }
            
            // MARK: Total Section
            Section(header: Text("TOTAL & DISCOUNT")) {
                HStack {
                    Image.SFOrder.totalAfterDiscount.font(Font.body.bold())
                    Text("Total").bold()
                    Spacer()
                    Text(model.totalAfterDiscount).bold()
                }
                
                HStack {
                    Image.SFOrder.totalBeforeDiscount
                    Text("Before Discount")
                    Spacer()
                    Text(model.totalBeforeDiscount)
                }
                
                HStack {
                    Image.SFOrder.discount
                    Text("Discount")
                    CurrencyTextField(text: $model.discount)
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
            setupRowActionSection()
        }
        .sheet(
            isPresented: $showModalPresentationSheet,
            onDismiss: dismissPresentationSheet,
            content: { self.modalPresentationSheet }
        )
        
        return setupNavItems(forForm: form.eraseToAnyView())
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
            .eraseToAnyView()
            
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
            .eraseToAnyView()
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
        .foregroundColor(.primary)
    }
}


// MARK: - Add Order Item Form

extension OrderForm {
    
    /// A form used to add order item to the order.
    var addOrderItemForm: some View {
        NavigationView {
            OrderItemForm(
                orderItemModel: $newOrderItemModel,
                saleItems: saleItemDataSource.fetchedResult.fetchedObjects ?? [],
                onAdd: addOrderItem,
                onCancel: dismissPresentationSheet
            )
                .navigationBarTitle("Add Item", displayMode: .inline)
        }
    }
    
    /// Add order item to the order
    func addOrderItem() {
        guard let order = model.order, let context = order.managedObjectContext else { return }
        let newOrderItem = OrderItem(context: context)
        newOrderItemModel.assign(to: newOrderItem)
        order.orderItems.insert(newOrderItem)
        model.orderItemCount = order.orderItems.count
        dismissPresentationSheet()
    }
}


// MARK: - Edit Order Item Form

extension OrderForm {
    
    /// A form used to edit order's item.
    var editOrderItemForm: some View {
        NavigationView {
            OrderItemForm(
                orderItemModel: $editOrderItemModel,
                onDone: dismissPresentationSheet,
                onDelete: deleteEditingOrderItem
            )
                .navigationBarTitle("Edit Details", displayMode: .inline)
        }
    }
    
    /// Delete the current editing order's item.
    func deleteEditingOrderItem() {
        guard let item = editOrderItemModel.orderItem, let order = item.order else { return }
        guard let context = item.managedObjectContext else { return }
        order.orderItems.remove(item)
        context.delete(item)
        model.orderItemCount = order.orderItems.count
        dismissPresentationSheet()
    }
}


// MARK: - Customer Selection List View

extension OrderForm {
    
    /// A list view displaying all customers for user to select.
    var customerSelectionView: some View {
        NavigationView {
            List {
                ForEach(customerDataSource.fetchedResult.fetchedObjects ?? [], id: \.self) { customer in
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
                    .layoutPriority(1)
                if customer.objectID == self.model.order?.customer?.objectID {
                    Spacer()
                    Image(systemName: "checkmark")
                        .imageScale(.small)
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
        modalPresentationSheet = customerSelectionView.eraseToAnyView()
        showModalPresentationSheet = true
    }
    
    /// Present `editOrderItemForm` sheet.
    func showEditOrderItemForm(with item: OrderItem) {
        editOrderItemModel = .init(orderItem: item)
        modalPresentationSheet = editOrderItemForm.eraseToAnyView()
        showModalPresentationSheet = true
    }
    
    /// Present `addOrderItemForm` sheet.
    func showAddOrderItemForm() {
        newOrderItemModel = .init()
        modalPresentationSheet = addOrderItemForm.eraseToAnyView()
        showModalPresentationSheet = true
    }
}


struct OrderForm_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    static var previews: some View {
        OrderForm(model: .constant(.init()))
    }
}
