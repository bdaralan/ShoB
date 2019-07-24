//
//  Home.swift
//  ShoB
//
//  Created by Dara Beng on 7/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct Home: View {
    
    @ObjectBinding var orderDataSource: FetchedDataSource<Order> = {
        let dataSource = FetchedDataSource<Order>(context: CoreDataStack.current.mainContext)
        let request = dataSource.fetchController.fetchRequest
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(Order.discount), ascending: true)]
        dataSource.performFetch()
        
        // reset code
        dataSource.fetchController.fetchedObjects?.forEach {
            dataSource.context.delete($0)
        }
        dataSource.context.quickSave()
        
        return dataSource
    }()
    
    @ObjectBinding var saleItemDataSource: FetchedDataSource<SaleItem> = {
        let dataSource = FetchedDataSource<SaleItem>(context: CoreDataStack.current.mainContext)
        let request = dataSource.fetchController.fetchRequest
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(SaleItem.name), ascending: true)]
        dataSource.performFetch()
        
//        // reset code
//        dataSource.fetchController.fetchedObjects?.forEach {
//            dataSource.context.delete($0)
//        }
//        dataSource.context.quickSave()
        
        return dataSource
    }()
    
    @ObjectBinding var customerDataSource: FetchedDataSource<Customer> = {
        let dataSource = FetchedDataSource<Customer>(context: CoreDataStack.current.mainContext)
        let request = dataSource.fetchController.fetchRequest
        request.predicate = .init(value: true)
        request.sortDescriptors = [
            .init(key: #keyPath(Customer.givenName), ascending: true),
            .init(key: #keyPath(Customer.familyName), ascending: true)
        ]
        dataSource.performFetch()
        
        // reset code
        dataSource.fetchController.fetchedObjects?.forEach {
            dataSource.context.delete($0)
        }
        
        let customer1 = Customer(context: dataSource.context)
        customer1.organization = "C1"
        let customer2 = Customer(context: dataSource.context)
        customer2.organization = "C2"
        
        dataSource.context.quickSave()
        
        return dataSource
    }()
    
    @State private var selectedTab = 1
    
    
    // MARK: - Body
    
    var body: some View {
        TabbedView(selection: $selectedTab) {
            // MARK: Order List
            NavigationView {
                OrderListView()
                    .environmentObject(orderDataSource)
                    .environmentObject(saleItemDataSource)
                    .environmentObject(customerDataSource)
                    .navigationBarTitle("Orders", displayMode: .large)
            }
            .tabItem {
                Image(systemName: "cube.box.fill")
                Text("Orders")
            }.tag(0)
            
            // MARK: Customer List
            NavigationView {
                CustomerListView()
                    .environmentObject(customerDataSource)
                    .navigationBarTitle("Customers", displayMode: .large)
            }
            .tabItem {
                Image(systemName: "rectangle.stack.person.crop.fill")
                Text("Customers")
            }.tag(1)
            
            // MARK: Sale Item List
            NavigationView {
                SaleItemListView()
                    .environmentObject(saleItemDataSource)
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
