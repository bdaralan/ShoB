//
//  OrderList.swift
//  ShoB
//
//  Created by Dara Beng on 6/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct OrderList: View {
    
    @State var orders = sampleOrders()

    @State private var currentSegment: Segment = .today
    
    @State private var segments: [Segment] = [.today, .tomorrow, .past7Days]
    
    
    var body: some View {
        List {
            SegmentedControl(selection: $currentSegment) {
                ForEach(segments.identified(by: \.self)) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            
            ForEach(orders) { order in
                NavigationButton(destination: OrderForm(mode: .view, order: order), label: {
                    Text("Order with discount: \(order.discount)")
                })
            }
        }
        .navigationBarTitle(Text("Orders"), displayMode: .large)
        .navigationBarItems(trailing:
            PresentationButton(destination: NavigationView { OrderForm(mode: .create, order: orders[0]) }, label: {
                Image(systemName: "plus").imageScale(.large)
            })
        )
    }
}


extension OrderList {
    
    enum Segment: String {
        case today = "Today"
        case tomorrow = "Tomorrow"
        case past7Days = "Past 7 Days"
        case all = "All"
    }
}


#if DEBUG
struct OrderList_Previews : PreviewProvider {
    static var previews: some View {
        OrderList()
    }
}
#endif


func sampleOrders() -> [Order] {
    let context = CoreDataStack.current.mainContext
    var orders = [Order]()
    for i in 1...30 {
        let order = Order(context: context)
        order.discount = Cent(i * 10)
        orders.append(order)
    }
    return orders
}
