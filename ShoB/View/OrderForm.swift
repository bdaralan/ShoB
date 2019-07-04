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
    
    @EnvironmentObject var order: Order
    
    @State var isDelivering = false
    @State var deliveryDate = Date()
    
    @State var isDelivered = false
    @State var deliveredDate = Date()
    
    @State var discountText = ""
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()
    
    
    var body: some View {
        Form {
            // MARK: Order Details Section
            Section(header: Text("ORDER DETAILS")) {
                DatePicker("Order Date", date: $order.orderDate)

                Toggle("Delivery", isOn: $isDelivering)
                if isDelivering {
                    DatePicker("Delivery Date", date: $deliveryDate)
                }

                Toggle("Delivered", isOn: $isDelivered)
                if isDelivered {
                    DatePicker("Delivered Date", date: $deliveredDate)
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
//                    TextField("$0.00", value: $order.discount, formatter: OrderForm.currencyFormatter)
//                        .multilineTextAlignment(.trailing)
                    UITextFieldView(text: $discountText, setup: { textField in
                        textField.keyboardType = .numberPad
                        textField.textAlignment = .right
                        textField.placeholder = "$0.00"
                    }, showToolBar: true, onEditingChanged: { textField in
                        let discount = Currency.parseCent(textField.text ?? "")
                        textField.text = discount == 0 ? "" : "\(Currency(discount))"
                        print(self.order.discount)
                    })
                }
            }
            
            // MARK: Order Items Section
            Section(header: Text("ORDER ITEMS")) {
                NavigationLink("Add Item", destination: saleItemList).foregroundColor(.accentColor)
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
        OrderForm().environmentObject(sampleOrders().first!)
    }
}
#endif
