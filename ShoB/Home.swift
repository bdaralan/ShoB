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
        dataSource.performFetch(Store.requestObjects())
        return dataSource
    }()
    
    @ObservedObject private var coreDataObserver = NotificationObserver(name: CoreDataStack.nCoreDataStackDidChange)
    
    @State private var selectedTab = HomeTab.order
    
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: Order List
            NavigationView {
                OrderListView()
                    .environmentObject(orderDataSource)
                    .environmentObject(saleItemDataSource)
                    .environmentObject(customerDataSource)
                    .navigationBarTitle(Text(HomeTab.order.title), displayMode: .large)
            }
            .tabItem(HomeTab.order.tabItem)
            .tag(HomeTab.order)
            
            // MARK: Customer List
            NavigationView {
                CustomerListView()
                    .environmentObject(customerDataSource)
                    .navigationBarTitle(Text(HomeTab.customer.title), displayMode: .large)
            }
            .tabItem(HomeTab.customer.tabItem)
            .tag(HomeTab.customer)

            // MARK: Sale Item List
            NavigationView {
                SaleItemListView()
                    .environmentObject(saleItemDataSource)
                    .navigationBarTitle(Text(HomeTab.item.title), displayMode: .large)
            }
            .tabItem(HomeTab.item.tabItem)
            .tag(HomeTab.item)
            
            NavigationView {
                StoreListView()
                    .environmentObject(storeDataSource)
                    .navigationBarTitle(Text(HomeTab.store.title), displayMode: .large)
            }
            .tabItem(HomeTab.store.tabItem)
            .tag(HomeTab.store)
        }
        .onAppear(perform: setupOnAppear)
    }
    
    func setupOnAppear() {
        coreDataObserver.onReceived = { notification in
            DispatchQueue.main.async {
                self.orderDataSource.performFetch(Order.requestNoObject())
                self.saleItemDataSource.performFetch(SaleItem.requestNoObject())
                self.customerDataSource.performFetch(Customer.requestNoObject())
                self.storeDataSource.performFetch(Store.requestObjects())
                self.selectedTab = HomeTab.store
            }
        }
    }
}


// MARK: - Home Tab Enum

enum HomeTab {
    case order
    case customer
    case item
    case store
    
    var title: String {
        switch self {
        case .order: return "Orders"
        case .customer: return "Customers"
        case .item: return "Items"
        case .store: return "Stores"
        }
    }
    
    var systemImage: String {
        switch self {
        case .order: return "cube.box.fill"
        case .customer: return "rectangle.stack.person.crop.fill"
        case .item: return "list.dash"
        case .store: return "folder.fill"
        }
    }
    
    func tabItem() -> some View {
        Group {
            Image(systemName: systemImage)
            Text(title)
        }
    }
}


struct Home_Previews : PreviewProvider {
    static var previews: some View {
        Home()
    }
}
