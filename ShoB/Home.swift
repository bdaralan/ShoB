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
    
    @ObservedObject var orderDataSource = OrderDataSource(parentContext: CoreDataStack.current.mainContext)
    
    @ObservedObject var saleItemDataSource = SaleItemDataSource(parentContext: CoreDataStack.current.mainContext)
    
    @ObservedObject var customerDataSource = CustomerDataSource(parentContext: CoreDataStack.current.mainContext)
    
    @ObservedObject var storeDataSource: StoreDataSource = {
        let dataSource = StoreDataSource(parentContext: CoreDataStack.current.mainContext)
        dataSource.performFetch(Store.requestAllStores())
        return dataSource
    }()
    
    @State private var selectedTab = 0
    
    @ObservedObject private var coreDataNotification = NotificationObserver(name: CoreDataStack.nCoreDataStackDidChange)
    
    
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
        .onAppear(perform: setupOnAppear)
    }
    
    func tabItem(systemImage: String, title: String) -> some View {
        ViewBuilder.buildBlock(Image(systemName: systemImage), Text(title))
    }
    
    func setupOnAppear() {
        coreDataNotification.onReceived = { notification in
            DispatchQueue.main.async {
                self.orderDataSource.performFetch()
                self.saleItemDataSource.performFetch()
                self.customerDataSource.performFetch()
                self.storeDataSource.performFetch()
                self.selectedTab = 3
            }
        }
    }
}


struct Home_Previews : PreviewProvider {
    static var previews: some View {
        Home()
    }
}
