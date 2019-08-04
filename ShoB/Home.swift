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
    
    @ObservedObject var orderDataSource: FetchedDataSource<Order> = {
        let dataSource = FetchedDataSource<Order>(context: CoreDataStack.current.mainContext)
        dataSource.performFetch(Order.requestDeliverToday())
        return dataSource
    }()
    
    @ObservedObject var saleItemDataSource: FetchedDataSource<SaleItem> = {
        let dataSource = FetchedDataSource<SaleItem>(context: CoreDataStack.current.mainContext)
        let request = dataSource.fetchController.fetchRequest
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(SaleItem.name), ascending: true)]
        dataSource.performFetch()
        return dataSource
    }()
    
    @ObservedObject var customerDataSource: FetchedDataSource<Customer> = {
        let dataSource = FetchedDataSource<Customer>(context: CoreDataStack.current.mainContext)
        let request = dataSource.fetchController.fetchRequest
        request.predicate = .init(value: true)
        request.sortDescriptors = [
            .init(key: #keyPath(Customer.givenName), ascending: true),
            .init(key: #keyPath(Customer.familyName), ascending: true)
        ]
        dataSource.performFetch()
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
