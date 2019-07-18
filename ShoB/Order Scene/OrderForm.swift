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
        var isDelivering = false
        var isDelivered = false
        var orderDate = Date()
        var deliveryDate = Date()
        var deliveredDate = Date()
        var discount = ""
        var note = ""
        
        /// Check whether the order has changed values.
        /// Always `false` if the `order` is `nil`.
        var hasOrderValueChanged: Bool {
            return order?.hasPersistentChangedValues ?? false
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
        
        
        /// Assign the model's values to the order.
        func assign() {
            // DEVELOPER NOTE:
            // Update the logic when needed.
            guard let order = order else { return }
            order.orderDate = orderDate
            order.deliveryDate = isDelivering ? deliveryDate : nil
            order.deliveredDate = isDelivered ? deliveredDate : nil
            order.discount = Currency.parseCent(from: discount)
            order.note = note
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
