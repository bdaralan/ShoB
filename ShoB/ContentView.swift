//
//  ContentView.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct ContentView : View {
    
    @ObjectBinding var order = Order(context: CoreDataStack.current.mainContext)
    @State private var selectedTab = 0
    
    var body: some View {
        TabbedView(selection: $selectedTab) {
            NavigationView {
                OrderList()
            }
            .tabItemLabel(Text("Orders")).tag(0)

            NavigationView {
                SaleItemList()
                    .navigationBarTitle(Text("Items"))
            }
            .tabItemLabel(Text("Items")).tag(1)
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
