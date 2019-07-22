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
    @State private var newOrderItemModel = SaleItemForm.Model()
    
    @State private var showSaleItemList = false
    
    
    // MARK: - Body
    
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
                
                // MARK: Add Button
                Button(action: { self.showSaleItemList = true }, label: {
                    HStack {
                        Text("Add Item")
                        Spacer()
                        Image(systemName: "plus.circle").imageScale(.medium)
                    }
                })
                
                // MARK: Order Item List
                if model.order != nil {
                    ForEach(model.order!.orderItems.sorted(by: { $0.name < $1.name }), id: \.self) { item in
                        NavigationLink("\(item.name) | \(item.subtotal)", destination: Text("\(item.name)"))
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
            isPresented: $showSaleItemList,
            onDismiss: dismissAddOrderItemForm,
            content: { self.addOrderItemForm }
        )
    }
    
    
    // MARK: - Body Component
    
    var addOrderItemForm: some View {
        NavigationView {
            Form {
                // Input Section
                Section(header: Text("ORDER ITEM")) {
                    SaleItemForm.BodyView(model: self.$newOrderItemModel, mode: .addItemToOrder)
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
            .navigationBarTitle("Order's Item", displayMode: .inline)
            .navigationBarItems(leading: cancelOrderItemNavItem, trailing: addOrderItemNavItem)
        }
    }
    
    var addOrderItemNavItem: some View {
        Button("Add", action: {
            guard let order = self.model.order, let context = order.managedObjectContext else { return }
            
            // create order item and add it to the order
            let newOrderItem = OrderItem(context: context)
            newOrderItem.order = order
            self.newOrderItemModel.assign(to: newOrderItem)
            
            // send change to reload form's Update button's state
            order.willChange.send()
            
            self.dismissAddOrderItemForm()
        })
    }
    
    var cancelOrderItemNavItem: some View {
        Button("Cancel", action: dismissAddOrderItemForm)
    }
    
    
    // MARK: - Method
    
    func dismissAddOrderItemForm() {
        self.showSaleItemList = false
        self.newOrderItemModel = .init()
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
