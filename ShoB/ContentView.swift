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
            // MARK: Order List
            NavigationView {
                OrderList()
                    .navigationBarTitle(Text("Orders"), displayMode: .large)
            }
            .tabItemLabel(
                VStack {
                    Image(systemName: "cube.box.fill")
                    Text("Orders")
                }
            ).tag(0)

            // MARK: Sale Item List
            NavigationView {
                SaleItemList()
                    .navigationBarTitle(Text("Items"), displayMode: .large)
            }
            .tabItemLabel(
                VStack {
                    Image(systemName: "list.dash")
                    Text("Items")
                }
            ).tag(1)
            
            // MARK: Customer List
            NavigationView {
                CustomerList()
                    .navigationBarTitle(Text("Customers"), displayMode: .large)
            }
            .tabItemLabel(
                VStack {
                    Image(systemName: "rectangle.stack.person.crop.fill")
                    Text("Customers")
                }
            ).tag(2)
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
