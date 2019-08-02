//
//  OrderRow+ContentView.swift
//  ShoB
//
//  Created by Dara Beng on 8/1/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension OrderRow {
    
    struct ContentView: View {
        
        @ObservedObject var order: Order
    }
}


// MARK: - Body

extension OrderRow.ContentView {
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK: Customer & Note
            HStack {
                Group {
                    Image.SFCustomer.profile
                    Text("\(order.customer?.identity ?? "None")")
                }
                .foregroundColor(order.customer == nil ? .secondary : .primary)
                
                if !order.note.isEmpty {
                    Spacer()
                    Image.SFOrder.note
                }
            }
            .font(.title)
            
            // MARK: Order Date
            HStack {
                Image.SFOrder.orderDate
                Text("\(order.orderDate, formatter: DateFormatter.shortDateTime)")
            }
            
            // MARK: Delivery Date
            HStack {
                Image.SFOrder.delivery
                Text(order.deliveryDate == nil ? "No" : "\(order.deliveryDate!, formatter: DateFormatter.shortDateTime)")
            }
            
            // MARK: Delivered Date
            HStack {
                Image.SFOrder.delivered
                Text(order.deliveredDate == nil ? "No" : "\(order.deliveredDate!, formatter: DateFormatter.shortDateTime)")
            }
            
            // MARK: Total & Discount
            HStack {
                Image.SFOrder.totalBeforeDiscount
                Text(verbatim: "\(Currency(order.total))")
                spacerDivider
                Image.SFOrder.discount
                Text(verbatim: "\(Currency(order.discount))")
                spacerDivider
                Image.SFOrder.totalAfterDiscount
                Text(verbatim: "\(Currency(order.total - order.discount))").bold()
            }
        }
    }
    
    var spacerDivider: some View {
        Group {
            Spacer()
            Divider()
            Spacer()
        }
    }
}
