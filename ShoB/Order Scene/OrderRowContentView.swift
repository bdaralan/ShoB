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
            .padding(.top, 8)
            
            // MARK: Order Date
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
            
            // MARK: Total & Discount
            HStack {
                currencyText(image: Image.SFOrder.totalBeforeDiscount, amount: order.total)
                verticalDivider
                currencyText(image: Image.SFOrder.discount, amount: order.discount)
                verticalDivider
                currencyText(image: Image.SFOrder.totalAfterDiscount, amount: order.total - order.discount)
                    .font(Font.body.bold())
            }
        }
    }
}

    
// MARK: - Body Component

extension OrderRowContentView {
    
    /// Format text for the given date
    /// - Parameter date: The date to format.
    func formattedText(for date: Date?) -> Text {
        Text(date == nil ? "No" : "\(date!, formatter: DateFormatter.shortDateTime)")
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
