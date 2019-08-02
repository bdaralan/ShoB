//
//  OrderRowContentView.swift
//  ShoB
//
//  Created by Dara Beng on 8/1/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// The content view of the order row.
struct OrderRowContentView: View {

    @ObservedObject var order: Order
    
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK: Customer & Note
            HStack {
                Group {
                    Image.SFCustomer.profile
                    Text(order.customer?.identity ?? "None")
                }
                .foregroundColor(order.customer == nil ? .secondary : .primary)
                
                if !order.note.isEmpty {
                    Spacer()
                    Image.SFOrder.note
                }
            }
            .font(.title)
            
            // MARK: Order Date
            dateText(image: Image.SFOrder.orderDate, date: order.orderDate)
            dateText(image: Image.SFOrder.delivery, date: order.deliveryDate)
            dateText(image: Image.SFOrder.delivered, date: order.deliveredDate)
            
            // MARK: Total & Discount
            HStack {
                currencyText(image: Image.SFOrder.totalBeforeDiscount, amount: order.total)
                verticalDivider
                currencyText(image: Image.SFOrder.discount, amount: order.discount)
                verticalDivider
                currencyText(image: Image.SFOrder.totalAfterDiscount, amount: order.total - order.discount)
            }
        }
    }
}

    
// MARK: - Body Component

extension OrderRowContentView {
    
    /// View displaying imag and text for date.
    /// - Parameter image: Image to display.
    /// - Parameter date: Date to display.
    func dateText(image: Image, date: Date?) -> some View {
        HStack {
            image
            Text(date == nil ? "No" : "\(date!, formatter: DateFormatter.shortDateTime)")
        }
    }
    
    /// View displaying image and currency amount.
    /// - Parameter image: Image to display.
    /// - Parameter amount: Amount to display.
    func currencyText(image: Image, amount: Cent) -> some View {
        ViewBuilder.buildBlock(image, Text(verbatim: "\(Currency(amount))"))
    }
    
    var verticalDivider: some View {
        ViewBuilder.buildBlock(Spacer(), Divider(), Spacer())
    }
}
