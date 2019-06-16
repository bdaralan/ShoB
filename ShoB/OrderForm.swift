//
//  OrderForm.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct OrderForm: View {
    
    @ObjectBinding var order: Order
    @State var discountText = "$0.00"
    
    var title: String = "Order Form"
    
    
    var body: some View {
        List {
            Section(header: Text("ORDER DETAILS"), footer: Text("\n")) {
                DatePicker($order.orderDate) {
                    Text("Order Date")
                }
                DatePicker($order.deliveryDate) {
                    Text("Delivery Date")
                }
            }
            
            Section(header: Text("TOTAL"), footer: Text("\n")) {
                HStack {
                    Text("After Discount")
                    
                    Spacer()
                    
                    Text(String(format: "$%.2f", Double(order.total - order.discount)))
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Before Discount")
                    
                    Spacer()
                    
                    Text(String(format: "$%.2f", Double(order.total)))
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Discount")
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    TextField($discountText, onEditingChanged: { (bool) in
                        self.order.discount = Int64(self.discountText) ?? Int64(0)
                    }, onCommit: {
                        self.order.discount = Int64(self.discountText) ?? Int64(0)
                    })
                    .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("ORDER ITEMS"), footer: Text("\n")) {
                NavigationButton(destination: Text("Item List").navigationBarTitle(Text("Add Item")), label: {
                    Text("Add Item").color(.secondary)
                })
            }
            
            Section(header: Text("NOTE")) {
                TextField($order.note)
                    .frame(minHeight: 200)
                    .lineLimit(nil)
            }
            
        }
        .navigationBarTitle(Text(title), displayMode: .inline)
        .listStyle(.grouped)
    }
}


#if DEBUG
struct OrderForm_Previews : PreviewProvider {
    static var previews: some View {
        OrderForm(order: sampleOrders().first!)
    }
}
#endif
