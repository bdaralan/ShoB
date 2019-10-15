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
                        .font(Font.orderRowFocusInfo.weight(.regular))
                    Text(order.customer?.identity ?? "None")
                        .font(.orderRowFocusInfo)
                }
                .foregroundColor(order.customer == nil ? .secondary : .primary)
                
                Spacer()
                Image.SFOrder.note
                    .font(.orderRowFocusInfo)
                    .hidden(order.note.isEmpty)
            }
            .padding(.top, 8)
            
            HStack(alignment: .top) {
                // MARK: Order Date
                VStack(alignment: .leading) {
                    HStack {
                        Image.SFOrder.orderDate
                        formattedText(for: order.orderDate)
                    }
                    HStack {
                        Image.SFOrder.deliverDate
                        formattedText(for: order.deliverDate)
                    }
                    HStack {
                        Image.SFOrder.delivered
                            .foregroundColor(order.deliveredDate != nil ? .green : .primary)
                        formattedText(for: order.deliveredDate)
                    }
                }
                
                Spacer()
                
                // MARK: Total & Discount
                VStack(alignment: .trailing) {
                    HStack {
                        Text(verbatim: "\(Currency(order.subtotal()))")
                        Image.SFOrder.totalBeforeDiscount
                    }
                    HStack {
                        Text(verbatim: "\(Currency(order.discount))")
                        Image.SFOrder.discount
                    }
                    HStack {
                        Text(verbatim: "\(Currency(order.total()))")
                            .font(.orderRowFocusInfo)
                        Image.SFOrder.totalAfterDiscount
                    }
                }
            }
        }
    }
}

    
// MARK: - Body Component

extension OrderRowContentView {
    
    /// Format text for the given date
    /// - Parameter date: The date to format.
    func formattedText(for date: Date?) -> Text {
        Text(date == nil ? "No" : "\(date!, formatter: DateFormatter.shortTime)")
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
