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
    
    @EnvironmentObject var saleItemDataSource: FetchedDataSource<SaleItem>
    
    /// Model used to create order.
    @Binding var model: Model
    
    /// Model used to create and add item to the order.
    @State private var itemToAddModel = SaleItemFormModel()
    
    @State private var showSaleItemList = false
    
    
    // MARK: - View Body
    
    var body: some View {
        Form {
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
                Button("Add Item", action: { self.showSaleItemList = true })
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
            isPresented: $showSaleItemList,
            onDismiss: dismissSaleItemList,
            content: { self.saleItemList }
        )
    }
    
    
    // MARK: - View Component
    
    var saleItemList: some View {
        NavigationView {
            Form {
                Section(header: Text("ORDER ITEM")) {
                    SaleItemFormView(model: self.$itemToAddModel, showQuantity: true)
                }
                
                Section(header: Text("ALL SALE ITEMS")) {
                    ForEach(saleItemDataSource.fetchController.fetchedObjects ?? []) { item in
                        Button(action: {
                            self.itemToAddModel = self.orderItemToAddModel(from: item)
                        }, label: {
                            HStack {
                                Text("\(item.name)")
                                Spacer()
                                Text(verbatim: "\(Currency(item.price))")
                            }.accentColor(.primary)
                        })
                    }
                }
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            .navigationBarItems(leading: cancelOrderItemNavItem, trailing: addOrderItemNavItem)
        }
    }
    
    var addOrderItemNavItem: some View {
        Button("Add", action: {
            guard let order = self.model.order, let context = order.managedObjectContext else { return }
            
            let newOrderItem = OrderItem(context: context)
            newOrderItem.order = order
            self.itemToAddModel.assign(to: newOrderItem)
            
            self.dismissSaleItemList()
            
            print(self.model.order!.orderItems)
        })
    }
    
    var cancelOrderItemNavItem: some View {
        Button("Cancel", action: dismissSaleItemList)
    }
    
    
    // MARK: - Method
    
    func dismissSaleItemList() {
        self.showSaleItemList = false
        self.itemToAddModel = .init()
    }
    
    /// Create a model from the given item's values.
    ///
    /// Once created, the item is set to `nil` to avoid modifying the actual item.
    /// - Parameter item: A model with `.saleItem = nil`.
    func orderItemToAddModel(from item: SaleItem) -> SaleItemFormModel {
        var model = SaleItemFormModel(item: item)
        model.saleItem = nil
        return model
    }
}


// MARK: - View Model

extension OrderForm {
    
    struct Model {
        weak var order: Order?
        
        var isDelivering = false {
            didSet { self.order?.deliveryDate = isDelivering ? Date.currentYMDHM : nil }
        }
        
        var isDelivered = false {
            didSet { self.order?.deliveredDate = isDelivered ? Date.currentYMDHM : nil }
        }
        
        var orderDate = Date.currentYMDHM {
            didSet { self.order?.orderDate = orderDate }
        }
        
        var deliveryDate = Date.currentYMDHM {
            didSet { self.order?.deliveryDate = deliveryDate }
        }
        
        var deliveredDate = Date.currentYMDHM {
            didSet { self.order?.deliveredDate = deliveredDate }
        }
        
        @CurrencyWrapper(amount: 0)
        var discount: String {
            didSet { self.order?.discount = _discount.amount }
        }
        
        var note = "" {
            didSet { self.order?.note = note }
        }
        
        /// Total before discount.
        var totalBeforeDiscount: String {
            guard let order = order else { return "\(Currency(0))" }
            return "\(Currency(order.total))"
        }
        
        /// Total after discount.
        var totalAfterDiscount: String {
            guard let order = order else { return "\(Currency(0))" }
            return "\(Currency(order.total - order.discount))"
        }
        
        
        init(order: Order? = nil) {
            guard let order = order else { return }
            self.order = order
            orderDate = order.orderDate
            isDelivering = order.deliveryDate != nil
            isDelivered = order.deliveredDate != nil
            deliveryDate = isDelivering ? order.deliveryDate! : Date.currentYMDHM
            deliveredDate = isDelivered ? order.deliveredDate! : Date.currentYMDHM
            discount = order.discount == 0 ? "" : "\(Currency(order.discount))"
            note = order.note
        }
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
