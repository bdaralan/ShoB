//
//  Home.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// The root view of the application.
struct Home: View {
    
    @ObservedObject var orderDataSource: OrderDataSource = {
        let dataSource = OrderDataSource(parentContext: CoreDataStack.current.mainContext)
        dataSource.performFetch(Order.requestDeliverToday())
        return dataSource
    }()
    
    @ObservedObject var saleItemDataSource: SaleItemDataSource = {
        let dataSource = SaleItemDataSource(parentContext: CoreDataStack.current.mainContext)
        dataSource.performFetch(SaleItem.requestAllObjects())
        return dataSource
    }()
    
    @ObservedObject var customerDataSource: CustomerDataSource = {
        let dataSource = CustomerDataSource(parentContext: CoreDataStack.current.mainContext)
        dataSource.performFetch(Customer.requestAllCustomer())
        return dataSource
    }()
    
    @ObservedObject var storeDataSource: StoreDataSource = {
        let dataSource = StoreDataSource(parentContext: CoreDataStack.current.mainContext)
        dataSource.performFetch(Store.requestAllStores())
        return dataSource
    }()
    
    @State private var selectedTab = 0
    
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: Order List
            NavigationView {
                OrderListView()
                    .environmentObject(orderDataSource)
                    .environmentObject(saleItemDataSource)
                    .environmentObject(customerDataSource)
                    .navigationBarTitle("Orders", displayMode: .large)
            }
            .tabItem { tabItem(systemImage: "cube.box.fill", title: "Orders") }
            .tag(0)
            
            // MARK: Customer List
            NavigationView {
                CustomerListView()
                    .environmentObject(customerDataSource)
                    .navigationBarTitle("Customers", displayMode: .large)
            }
            .tabItem { tabItem(systemImage: "rectangle.stack.person.crop.fill", title: "Customers") }
            .tag(1)

            // MARK: Sale Item List
            NavigationView {
                SaleItemListView()
                    .environmentObject(saleItemDataSource)
                    .navigationBarTitle("Items", displayMode: .large)
            }
            .tabItem { tabItem(systemImage: "list.dash", title: "Items") }
            .tag(2)
            
            NavigationView {
                StoreListView()
                    .environmentObject(storeDataSource)
                    .navigationBarTitle("Store", displayMode: .large)
            }
            .tabItem { tabItem(systemImage: "folder.fill", title: "Store") }
            .tag(3)
        }
    }
    
    func tabItem(systemImage: String, title: String) -> some View {
        ViewBuilder.buildBlock(Image(systemName: systemImage), Text(title))
    }
}

#if DEBUG
struct Home_Previews : PreviewProvider {
    static var previews: some View {
        Home()
    }
}
#endif
