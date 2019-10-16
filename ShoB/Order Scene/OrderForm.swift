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
    
    /// Flag used to show `modalSheet`.
    @State private var showModalSheet = false
    
    /// A modal presentation sheet.
    ///
    /// The sheet can be set and used to present:
    /// - add or edit order item form
    /// - customer selection list
    @State private var modalSheet = AnyView.emptyView
    
    /// A flag to show or hide model text view keyboard.
    @State private var isNoteTextViewActive = false
    
    @State private var isDiscountTextFieldActive = false
    
    
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
                .foregroundColor(.primary)
                
                DatePicker(selection: $model.deliverDate) {
                    Image.SFOrder.deliverDate
                    Text("Deliver Date")
                }
                .foregroundColor(.primary)

                Toggle(isOn: $model.isDelivered) {
                    Image.SFOrder.delivered
                    Text("Delivered")
                }
                
                DatePicker(selection: $model.deliveredDate) {
                    Image.SFOrder.delivered.foregroundColor(.green)
                    Text("Delivered Date")
                }
                .foregroundColor(.primary)
                .hidden(!model.isDelivered)
            }
            
            // MARK: Total Section
            Section(header: Text("TOTAL & DISCOUNT")) {
                HStack {
                    Image.SFOrder.totalBeforeDiscount
                    Text("Subtotal")
                    Spacer()
                    Text(model.totalBeforeDiscount)
                }
                
                Button(action: beginEditingDiscount) {
                    HStack {
                        Image.SFOrder.discount
                        Text("Discount")
                        Spacer()
                        Text("\(model.discount)")
                    }
                    .foregroundColor(.primary)
                }
                
                HStack {
                    Image.SFOrder.totalAfterDiscount
                    Text("Total").font(.orderRowFocusInfo)
                    Spacer()
                    Text(model.totalAfterDiscount).font(.orderRowFocusInfo)
                }
            }
            
            // MARK: Order Items Section
            Section(header: Text("ORDER ITEMS")) {
                
                // Add Item Button
                Button(action: showAddOrderItemForm) {
                    HStack {
                        Text("Add Item")
                        Spacer()
                        Image.SFOrder.addOrderItem.imageScale(.large)
                    }
                }
                
                // Order Item List
                ForEach(model.order?.orderItems.sorted(by: { $0.name < $1.name }) ?? [], id: \.self) { item in
                    Button(action: { self.showEditOrderItemForm(with: item) }) {
                        OrderItemRow(orderItem: item)
                    }
                }
            }

            // MARK: Note Section
            Section(header: Text("NOTE")) {
                VStack {
                    Text(model.note.isEmpty ? ". . ." : model.note)
                        .foregroundColor(model.note.isEmpty ? .secondary : .primary)
                }
                .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
                .padding([.top, .bottom])
                .contentShape(Rectangle())
                .onTapGesture(perform: beginEditOrderNote)
            }
            
            setupRowActionSection()
        }
        .sheet(isPresented: $showModalSheet, onDismiss: dismissPresentationSheet, content: { self.modalSheet })
        
        return setupNavItems(forForm: form.eraseToAnyView())
    }
}


// MARK: - Form Row

extension OrderForm {
    
    /// Customer row displaying selected customer
    func customerRow(for customer: Customer?) -> some View {
        let rowContent: AnyView
        
        if let customer = customer {
            rowContent = CustomerRowContentView(customer: customer)
                .foregroundColor(.primary)
                .eraseToAnyView()
            
        } else { // no customer selected
            rowContent = HStack {
                Image.SFCustomer.profile
                Text("None")
                Spacer()
                Text("Select Customer")
            }
            .foregroundColor(.secondary)
            .eraseToAnyView()
        }
        
        return Button(action: showCustomerSelectionView) {
            rowContent
        }
    }
}


extension OrderForm {
    
    var orderDiscountEditingSheet: some View {
        ModalInputField(
            mode: .textfield,
            text: $model.discount,
            isActive: $isDiscountTextFieldActive,
            prompt: "Discount",
            placeholder: "$0.00",
            keyboard: .numberPad,
            returnKey: .done,
            onDone: commitEditingDiscount
        )
    }
    
    func beginEditingDiscount() {
        modalSheet = orderDiscountEditingSheet.eraseToAnyView()
        isDiscountTextFieldActive = true
        showModalSheet = true
    }
    
    func commitEditingDiscount() {
        isDiscountTextFieldActive = false
        showModalSheet = false
    }
}


// MARK: Note Edit Sheet

extension OrderForm {
    
    var orderNoteEditingSheet: some View {
        ModalInputField(
            mode: .textview,
            text: $model.note,
            isActive: $isNoteTextViewActive,
            prompt: "Note",
            onDone: commitEditOrderNote
        )
    }
    
    func beginEditOrderNote() {
        modalSheet = orderNoteEditingSheet.eraseToAnyView()
        showModalSheet = true
        isNoteTextViewActive = true
    }
    
    func commitEditOrderNote() {
        showModalSheet = false
        isNoteTextViewActive = false
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
                .navigationBarTitle("Edit Item", displayMode: .inline)
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
        Button("Cancel", action: { self.showModalSheet = false })
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
                        .imageScale(.medium)
                }
            }
        }
    }
    
    /// Assign a customer to the order or `nil` for no customer.
    /// - Parameter customer: The customer to assign or `nil`.
    func selectCustomer(_ customer: Customer?) {
        if let customer = customer, let context = model.order?.managedObjectContext {
            model.order?.customer = customer.get(from: context)
        } else {
            model.order?.customer = nil
        }
        showModalSheet = false
    }
}


// MARK: - Method

extension OrderForm {
    
    /// Dismiss the presenting add or edit order form sheet and clean up as needed.
    func dismissPresentationSheet() {
        showModalSheet = false
        isDiscountTextFieldActive = false
        isNoteTextViewActive = false
        
        // trim the note text if user drags to dismiss the modal
        model.note = model.note.trimmed()
        
        // for add-order-item form or customer-selection list, just dismiss
        // for edit-order-item form, do some clean up and reload
        if editOrderItemModel.orderItem != nil, let order = model.order {
            order.objectWillChange.send()
            
            // manually mark order as has changed if its item has changed
            // because hasPersistentChangedValues only check the object property
            // but not its array's object's property
            let hasOrderItemsChanged = order.orderItems.map({ $0.hasChangedValues() }).contains(true)
            order.isMarkedValuesChanged = hasOrderItemsChanged
            
            // set orderItem to nil to avoid updating the item (safeguard)
            // the model is not set to .init() to prevent UI reloading while it is dismissing
            // because of @State
            editOrderItemModel.orderItem = nil
        }
    }
    
    /// Present `customerSelectionView` sheet.
    func showCustomerSelectionView() {
        modalSheet = customerSelectionView.eraseToAnyView()
        showModalSheet = true
    }
    
    /// Present `editOrderItemForm` sheet.
    func showEditOrderItemForm(with item: OrderItem) {
        editOrderItemModel = .init(orderItem: item)
        modalSheet = editOrderItemForm.eraseToAnyView()
        showModalSheet = true
    }
    
    /// Present `addOrderItemForm` sheet.
    func showAddOrderItemForm() {
        newOrderItemModel = .init()
        modalSheet = addOrderItemForm.eraseToAnyView()
        showModalSheet = true
    }
}


struct OrderForm_Previews : PreviewProvider {
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    static var previews: some View {
        OrderForm(model: .constant(.init()))
    }
}
