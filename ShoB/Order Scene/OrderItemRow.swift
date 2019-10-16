//
//  OrderItemRow.swift
//  ShoB
//
//  Created by Dara Beng on 10/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view to display order item.
struct OrderItemRow: View {
    
    @ObservedObject var orderItem: OrderItem
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // MARK: Item & Total
                HStack {
                    Text(orderItem.name)
                    Spacer()
                    Text(Currency(orderItem.subtotal).description)
                }
                .foregroundColor(.primary)
                
                // MARK: Quantity
                HStack {
                    Text("\(orderItem.quantity)")
                        .frame(minWidth: 40, alignment: .leading)
                    Divider()
                        .hidden(orderItem.quantity < 12)
                    dozenText
                    Spacer()
                    Text(Currency(orderItem.price).description)
                }
                .font(.callout)
                .foregroundColor(.primary2)
            }
            
            // MARK: Edit Icon
            Image(systemName: "square.and.pencil")
                .imageScale(.large)
                .padding(.init(top: 0, leading: 8, bottom: 6, trailing: 0))
                .foregroundColor(.secondary)
        }
    }
}


extension OrderItemRow {
    
    var dozenText: some View {
        let dozenCount = Int64(OrderItemForm.QuantityMode.dozen.count)
        let dozen = orderItem.quantity / dozenCount
        let remain = orderItem.quantity % dozenCount
        let remainString = remain == 0 ? "" : " + \(remain)"
        
        if dozen == 0 {
            return EmptyView().eraseToAnyView()
        } else {
            return Text("\(dozen) doz.\(remainString)").eraseToAnyView()
        }
    }
}


struct OrderItemRow_Previews: PreviewProvider {
    static var previews: some View {
        OrderItemRow(orderItem: OrderItem(context: CoreDataStack.current.mainContext))
    }
}
