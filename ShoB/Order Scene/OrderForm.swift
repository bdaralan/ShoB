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
    
    @Binding var model: Model
    
    
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
                NavigationLink(destination: saleItemList, label: { Text("Add Item") })
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
    }
    
    
    // MARK: - View Component
    
    var saleItemList: some View {
        SaleItemListView { item, body in
            print(item)
        }
        .navigationBarTitle("Add Item")
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
