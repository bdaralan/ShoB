//
//  OrderForm.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine


struct OrderForm: View {
    
    @ObjectBinding var order: Order
    
    @State private var discountText: String = "\(Currency(0))"
    
    @State private var isOrderDelivered = false
    
    @State private var orderDeliveredDate = Date()
    
    var onCancel: (() -> Void)?
    var onCommit: (() -> Void)
    
    
    var body: some View {
        Form {
            // MARK: Order Details Section
            Section(header: Text("ORDER DETAILS")) {
                DatePicker($order.orderDate) {
                    Text("Order Date")
                }
                
                DatePicker($order.deliveryDate) {
                    Text("Delivery Date")
                }
                
                Toggle(isOn: $isOrderDelivered) {
                    Text("Delivered")
                }
                
                if isOrderDelivered {
                    DatePicker($orderDeliveredDate) {
                        Text("Delivered Date")
                    }
                }
            }
            
            // MARK: Total Section
            Section(header: Text("TOTAL")) {
                HStack {
                    Text("After Discount")
                    Spacer()
                    Text(Currency(order.total - order.discount).description)
                }
                
                HStack {
                    Text("Before Discount")
                    Spacer()
                    Text(Currency(order.total).description)
                }
                
                HStack {
                    Text("Discount")
                    TextField($discountText)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            // MARK: Order Items Section
            Section(header: Text("ORDER ITEMS")) {
                NavigationButton(destination: saleItemList, label: { Text("Add Item").color(.secondary) })
            }
            
            // MARK: Note Section
            Section(header: Text("NOTE")) {
                TextField($order.note)
                    .frame(minHeight: 200)
                    .lineLimit(nil)
            }
            
        }
        .navigationBarTitle(Text("Order Details"), displayMode: .inline)
        .modifier(CommitNavigationItems(
            onCancel: onCancel,
            onCommit: onCommit,
            commitTitle: "Update",
            modalCommitTitle: "Place Order"
        ))
    }
    
    var saleItemList: some View {
        SaleItemList { (item, body) in
            print(item)
        }
        .navigationBarTitle(Text("Add Item"))
    }
}


#if DEBUG
struct OrderForm_Previews : PreviewProvider {
    static var previews: some View {
        OrderForm(order: sampleOrders().first!, onCancel: nil, onCommit: { Void() })
    }
}
#endif
