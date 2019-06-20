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
    
    let mode: Mode
    
    @ObjectBinding var order: Order
    
    @State private var discountText: String = "\(Currency(0))"
    
    @State private var isOrderDelivered = false
    
    @State private var orderDeliveredDate = Date()
    
    var onCommit: ((OrderForm) -> Void)?

    
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
                NavigationButton(destination: saleItemListView(), label: { Text("Add Item").color(.secondary) })
            }
            
            // MARK: Note Section
            Section(header: Text("NOTE")) {
                TextField($order.note)
                    .frame(minHeight: 200)
                    .lineLimit(nil)
            }
            
        }
        .listStyle(.grouped)
        .navigationBarTitle(Text("Order Details"), displayMode: .inline)
        .navigationBarItems(trailing: Button(action: commitOrder, label: { commitLabel(for: mode) }))
    }
    
    // MARK: - Action
    
    func commitOrder() {
        onCommit?(self)
    }
    
    // MARK: - View
    
    func saleItemListView() -> some View {
        SaleItemList { (item, body) in
            print(item)
        }
        .navigationBarTitle(Text("Add Item"))
    }
    
    func commitLabel(for mode: Mode) -> some View {
        switch mode {
        case .create:
            return Text("Place Order")
        case .view:
            return Text("Update").color(order.deliveredDate == nil ? nil : .orange)
        }
    }
}


extension OrderForm {
    
    enum Mode {
        case create
        case view
    }
}


#if DEBUG
struct OrderForm_Previews : PreviewProvider {
    static var previews: some View {
        OrderForm(mode: .view, order: sampleOrders().first!)
    }
}
#endif
