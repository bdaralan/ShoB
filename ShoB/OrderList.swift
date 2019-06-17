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
    
    var body: some View {
        List(orders) { order in
            NavigationButton(
                destination: OrderForm(order: order),
                label: {
                    Text("Order with discount: \(order.discount)")
                }
            )
        }
        .navigationBarTitle(Text("Orders"), displayMode: .large)
        .navigationBarItems(trailing:
            PresentationButton( // add new order button
                Image(systemName: "plus")
                    .imageScale(.large),
                destination: Text("Order Form Create Mode")
            )
        )
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
    let o1 = Order(context: context)
    o1.discount = 10
    let o2 = Order(context: context)
    o2.discount = 20
    let o3 = Order(context: context)
    o3.discount = 30
    let o4 = Order(context: context)
    o4.discount = 40
    return [o1, o2, o3, o4]
}
