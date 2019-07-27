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
    
    @ObjectBinding var orderDataSource: FetchedDataSource<Order> = {
        let dataSource = FetchedDataSource<Order>(context: CoreDataStack.current.mainContext)
        let request = dataSource.fetchController.fetchRequest
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: #keyPath(Order.discount), ascending: true)]
        dataSource.performFetch()
        
        // reset code
//        dataSource.fetchController.fetchedObjects?.forEach {
//            dataSource.context.delete($0)
//        }
//        dataSource.context.quickSave()
        
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
        if dataSource.fetchController.fetchedObjects!.isEmpty {
            dataSource.fetchController.fetchedObjects?.forEach {
                dataSource.context.delete($0)
            }
            
            let customer1 = Customer(context: dataSource.context)
            customer1.givenName = "Tristana"
            customer1.familyName = "Yordle"
            customer1.organization = "Sumonner Rift"
            customer1.contact.phone = "562 111 2222"
            customer1.contact.email = "trist@email.com"
            customer1.contact.address = "1234 Rift Ave, Long Beach, CA 90805"
            
            let customer2 = Customer(context: dataSource.context)
            customer2.givenName = "Sivir"
            customer2.familyName = "Surima"
            customer2.organization = "Sand Empire"
            customer2.contact.phone = "562 444 5555"
            customer2.contact.email = "sivir@email.com"
            customer2.contact.address = "1010 Sand Ave, Long Beach, CA 90805"
            
            dataSource.context.quickSave()
        }
        
        return dataSource
    }()
    
    @State private var selectedTab = 1
    
    
    // MARK: - Body
    
    var body: some View {
        TabbedView {
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
