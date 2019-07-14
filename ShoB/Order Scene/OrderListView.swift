//
//  OrderListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData

struct OrderListView: View {
    
    @EnvironmentObject var cudDataSource: CUDDataSource<Order>
    
    @EnvironmentObject var orderDataSource: FetchedDataSource<Order>

    @State private var currentSegment = Segment.today
    
    @State private var segments = [Segment.today, .tomorrow, .past7Days]
    
    /// A flag used to present or dismiss `placeOrderForm`.
    @State private var showPlaceOrderForm = false
    
    
    var body: some View {
        List {
            // MARK: Segment Control
            SegmentedControl(selection: $currentSegment) {
                ForEach(segments.identified(by: \.self)) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            
            // MARK: Order Rows
            ForEach(orderDataSource.fetchController.fetchedObjects ?? []) { order in
                OrderRow(sourceOrder: order, dataSource: self.cudDataSource, onUpdated: nil)
            }
        }
        .navigationBarItems(trailing: placeNewOrderNavItem)
        .presentation(modalPlaceOrderForm)
    }
    
    
    var placeNewOrderNavItem: some View {
        Button(action: {
            self.cudDataSource.discardNewObject()
            self.cudDataSource.prepareNewObject()
            self.cudDataSource.didChange.send()
            self.showPlaceOrderForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
        .accentColor(.accentColor)
    }
    
    /// Construct an order form.
    /// - Parameter order: The order to view or pass `nil` get a create mode form.
    var modalPlaceOrderForm: Modal? {
        guard showPlaceOrderForm else { return nil }
        
        let dismiss = {
            self.cudDataSource.discardCreateContext()
            self.showPlaceOrderForm = false
        }
        
        let form = CreateOrderForm(dataSource: cudDataSource, onPlacedOrder: dismiss, onCancelled: dismiss)
        
        return Modal(NavigationView { form }, onDismiss: dismiss)
    }
}


extension OrderListView {
    
    enum Segment: String {
        case today = "Today"
        case tomorrow = "Tomorrow"
        case past7Days = "Past 7 Days"
        case all = "All"
    }
}


#if DEBUG
struct OrderList_Previews : PreviewProvider {
    static var previews: some View {
        OrderListView()
    }
}
#endif
