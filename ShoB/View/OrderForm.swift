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
    
    enum Mode {
        case create(NSManagedObjectContext)
        case view(Order)
    }
    
    let mode: Mode
    
    var order: Order
    
    @State private var discountText: String = ""
    
    @State private var isDelivering = false
    @State private var orderDeliveryDate = Date()
    
    @State private var isDelivered = false
    @State private var orderDeliveredDate = Date()
    
    var onCancel: ((Order) -> Void)?
    var onCommit: ((Order) -> Void)
    
    
    init(mode: Mode, onCancel: ((Order) -> Void)? = nil, onCommit: @escaping ((Order) -> Void)) {
        self.mode = mode
        self.onCancel = onCancel
        self.onCommit = onCommit
        
        switch mode {
        
        case .create(let context):
            self.order = Order(context: context)
        
        case .view(let order):
            self.order = order
        }
    }
    
    
    var body: some View {
        Form {
            // MARK: Order Details Section
            Section(header: Text("ORDER DETAILS")) {
//                DatePicker("Order Date", date: $order.orderDate)

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
                    Text(Currency(order.total).description)
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
                    })
                }
            }
            
            // MARK: Order Items Section
//            Section(header: Text("ORDER ITEMS")) {
//                NavigationButton(destination: saleItemList, label: { Text("Add Item").color(.secondary) })
//            }
//
//            // MARK: Note Section
//            Section(header: Text("NOTE")) {
//                VStack {
//                    TextField($order.note, placeholder: Text(". . ."))
//                        .lineLimit(nil)
//                        .padding([.top, .bottom])
//                    Spacer()
//                }
//                .frame(minHeight: 200)
//            }
            
        }
        .navigationBarTitle("Order Details", displayMode: .inline)
//        .modifier(CommitNavigationItems(
//            onCancel: onCancel == nil ? nil : cancelOrder,
//            onCommit: commitOrder,
//            commitTitle: "Update",
//            modalCommitTitle: "Place Order"
//        ))
    }
    
    var saleItemList: some View {
        SaleItemList { (item, body) in
            print(item)
        }
        .navigationBarTitle("Add Item")
    }
    
    func cancelOrder() {
        onCancel?(order)
    }
    
    func commitOrder() {
        order.deliveryDate = isDelivering ? orderDeliveryDate : nil
        order.deliveredDate = isDelivered ? orderDeliveredDate : nil
        onCommit(order)
    }
}


#if DEBUG
struct OrderForm_Previews : PreviewProvider {
    static var previews: some View {
        OrderForm(mode: .create(CoreDataStack.current.mainContext), onCommit: { _ in })
    }
}
#endif
