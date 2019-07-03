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


struct OrderForm: View {
    
    @ObjectBinding var order: Order
    
    @State private var isDelivering = false
    @State private var orderDeliveryDate = Date()
    
    @State private var isDelivered = false
    @State private var orderDeliveredDate = Date()
    
    @State private var discountText = ""
    
    
    var body: some View {
        Form {
            // MARK: Order Details Section
            Section(header: Text("ORDER DETAILS")) {
                DatePicker("Order Date", date: $order.orderDate)

                Toggle("Delivery", isOn: $isDelivering)
                if isDelivering {
                    DatePicker("Delivery Date", date: $orderDeliveryDate)
                }

                Toggle("Delivered", isOn: $isDelivered)
                if isDelivered {
                    DatePicker("Delivered Date", date: $orderDeliveredDate)
                }
            }
            
            // MARK: Total Section
            Section(header: Text("TOTAL")) {
                HStack {
                    Text("After Discount")
                    Spacer()
                    Text(verbatim: "\(Currency(order.total - order.discount))")
                }
                
                HStack {
                    Text("Before Discount")
                    Spacer()
                    Text(verbatim: "\(Currency(order.total))")
                }
                
                HStack {
                    Text("Discount")
                    UITextFieldView(text: $discountText, setup: { textField in
                        textField.keyboardType = .numberPad
                        textField.textAlignment = .right
                        textField.placeholder = "$0.00"
                    }, showToolBar: true, onEditingChanged: { textField in
                        let discount = Currency.parseCent(textField.text ?? "")
                        textField.text = discount == 0 ? "" : "\(Currency(discount))"
                        print(self.order.objectID)
                    })
                }
            }
            
            // MARK: Order Items Section
            Section(header: Text("ORDER ITEMS")) {
                NavigationLink(destination: saleItemList, label: { Text("Add Item").color(.accentColor) })
            }

            // MARK: Note Section
            Section(header: Text("NOTE")) {
                VStack {
                    TextField(". . .", text: $order.note)
                        .lineLimit(nil)
                        .padding([.top, .bottom])
                    Spacer()
                }
                .frame(minHeight: 200)
            }
        }
    }
    
    var saleItemList: some View {
        SaleItemListView { (item, body) in
            print(item)
        }
        .navigationBarTitle("Add Item")
    }
}


#if DEBUG
struct OrderForm_Previews : PreviewProvider {
    static var previews: some View {
        OrderForm(order: sampleOrders().first!)
    }
}
#endif
