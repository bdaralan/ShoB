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
    
    var discount: Binding<String> {
        .init(
            getValue: { self.order.discount == 0 ? "" : "\(Currency(self.order.discount))" },
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
                DatePicker("Order Date", selection: orderDate)

                Toggle("Delivery", isOn: isDelivering)
                if isDelivering.wrappedValue {
                    DatePicker("Delivery Date", selection: deliveryDate)
                }

                Toggle("Delivered", isOn: isDelivered)
                if isDelivered.wrappedValue {
                    DatePicker("Delivered Date", selection: deliveredDate)
                }
            }
            
            // MARK: Total Section
            Section(header: Text("TOTAL & DISCOUNT")) {
                HStack {
                    Text("Total").bold()
                    Spacer()
                    Text(verbatim: "\(Currency(order.total - order.discount))").bold()
                }
                
                HStack {
                    Text("Before Discount")
                    Spacer()
                    Text(verbatim: "\(Currency(order.total))")
                }
            }
            
            // MARK: Items Section
            Section(header: Text("ORDER ITEMS")) {
                NavigationLink(destination: saleItemList, label: { Text("Add Item") })
            }

//            // MARK: Note Section
//            Section(header: Text("NOTE")) {
//                VStack {
//                    TextField(". . .", text: note)
//                        .lineLimit(nil)
//                        .padding([.top, .bottom])
//                    Spacer()
//                }
//                .frame(minHeight: 200)
//            }
        }
    }
    
    
    var saleItemList: some View {
        SaleItemListView { item, body in
            print(item)
        }
        .navigationBarTitle("Add Item")
    }
}


#if DEBUG
struct OrderForm_Previews : PreviewProvider {
    
    static let order = Order(context: CoreDataStack.current.mainContext.newChildContext())
    
    static var previews: some View {
        OrderForm(order: order)
    }
}
#endif
