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
    
    var orderDate: Binding<Date> {
        .init(
            getValue: { self.order.orderDate },
            setValue: { self.order.orderDate = $0 }
        )
    }
    
    var isDelivering: Binding<Bool> {
        .init(
            getValue: { self.order.deliveryDate != nil },
            setValue: { self.order.deliveryDate = $0 ? Date() : nil }
        )
    }
    
    var deliveryDate: Binding<Date> {
        .init(
            getValue: { self.order.deliveryDate! },
            setValue: { self.order.deliveryDate = $0 }
        )
    }
    
    var isDelivered: Binding<Bool> {
        .init(
            getValue: { self.order.deliveredDate != nil },
            setValue: { self.order.deliveredDate = $0 ? Date() : nil }
        )
    }
    
    var deliveredDate: Binding<Date> {
        .init(
            getValue: { self.order.deliveredDate! },
            setValue: { self.order.deliveredDate = $0 }
        )
    }
    
    var discountText: Binding<String> {
        .init(
            getValue: { self.textForDiscount(self.order.discount) },
            setValue: { self.order.discount = Currency.parseCent(from: $0) }
        )
    }
    
    var note: Binding<String> {
        .init(
            getValue: { self.order.note },
            setValue: { self.order.note = $0 }
        )
    }
    
    
    var body: some View {
        Form {
            // MARK: Date Section
            Section(header: Text("ORDER DETAILS")) {
                DatePicker("Order Date", date: orderDate)

                Toggle("Delivery", isOn: isDelivering)
                if isDelivering.value {
                    DatePicker("Delivery Date", date: deliveryDate)
                }

                Toggle("Delivered", isOn: isDelivered)
                if isDelivered.value {
                    DatePicker("Delivered Date", date: deliveredDate)
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
                    UITextFieldView(text: discountText, setup: { textField in
                        textField.keyboardType = .numberPad
                        textField.textAlignment = .right
                        textField.placeholder = "$0.00"
                    }, showToolBar: true, onEditingChanged: { textField in
                        let text = textField.text ?? ""
                        let discount = Currency.parseCent(from: text)
                        textField.text = self.textForDiscount(discount)
                    })
                }
            }
            
            // MARK: Items Section
            Section(header: Text("ORDER ITEMS")) {
                NavigationLink("Add Item", destination: saleItemList).foregroundColor(.accentColor)
            }

            // MARK: Note Section
            Section(header: Text("NOTE")) {
                VStack {
                    TextField(". . .", text: note)
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
    
    
    /// Return text for discount text field.
    /// - Parameter discount: The discount to compute.
    func textForDiscount(_ discount: Cent) -> String {
        discount == 0 ? "" : "\(Currency(discount))"
    }
}


#if DEBUG
struct OrderForm_Previews : PreviewProvider {
    static var previews: some View {
        OrderForm(order: sampleOrders().first!)
    }
}
#endif
