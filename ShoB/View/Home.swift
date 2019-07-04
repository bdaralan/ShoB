//
//  Home.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct Home: View {
    
    @ObjectBinding var orderingDataSource = OrderingDataSource(context: CoreDataStack.current.mainContext)
    
    @ObjectBinding var orderDataSource: FetchedDataSource<Order> = {
        let dataSource = FetchedDataSource(context: CoreDataStack.current.mainContext, entity: Order.self)
        let request = dataSource.fetchController.fetchRequest
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(Order.discount), ascending: true)]
        dataSource.performFetch()
        return dataSource
    }()
    
    @State private var selectedTab = 0
    
    
    var body: some View {
        TabbedView {
            // MARK: Order List
            NavigationView {
                OrderListView()
                    .navigationBarTitle("Orders", displayMode: .large)
                    .environmentObject(orderingDataSource)
                    .environmentObject(orderDataSource)
            }
            .tabItem {
                Image(systemName: "cube.box.fill")
                Text("Orders")
            }.tag(0)
            
            // MARK: Customer List
            NavigationView {
                CustomerListView()
                    .navigationBarTitle("Customers", displayMode: .large)
            }
            .tabItem {
                Image(systemName: "rectangle.stack.person.crop.fill")
                Text("Customers")
            }.tag(1)
            
            // MARK: Sale Item List
            NavigationView {
                SaleItemListView()
                    .navigationBarTitle("Items", displayMode: .large)
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("Items")
            }.tag(2)
        }
    }
}

#if DEBUG
struct Home_Previews : PreviewProvider {
    static var previews: some View {
        Home()
    }
}
#endif
