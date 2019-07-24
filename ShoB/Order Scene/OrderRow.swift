//
//  OrderRow.swift
//  ShoB
//
//  Created by Dara Beng on 6/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


struct OrderRow: View {
    
    @EnvironmentObject var customerDataSource: FetchedDataSource<Customer>
    
    /// The order to view or update.
    @ObjectBinding var order: Order
    
    var onSave: (OrderForm.Model) -> Void
    
    @State private var orderModel = OrderForm.Model()
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: orderDetailView) { // row content
            VStack(alignment: .leading) {
                Text("Customer: \(order.customer?.identity ?? "None")")
                
                Text("Order Date:\t \(formatter.string(from: order.orderDate))")
                
                if order.deliveryDate == nil {
                    Text("Deliver:\t No")
                } else {
                    Text("Delivery Date:\t \(formatter.string(from: order.deliveryDate!))")
                }
                
                
                if order.deliveredDate == nil {
                    Text("Delivered:\t No")
                } else {
                    Text("Delivery Date:\t \(formatter.string(from: order.deliveredDate!))")
                }
                
                Text("Discount: \(order.discount)")
                
                Text("Note: \(order.note)")
            }
        }
    }

    
    // MARK: - Body Component
    
    var orderDetailView: some View {
        OrderDetailView(order: order, model: $orderModel, onSave: {
            self.onSave(self.orderModel)
        })
        .onAppear {
            // DEVELOPER NOTE:
            // Do the assignment here for now until finding a better place for the assignment
            print("DEVELOPER NOTE: OrderRow.orderDetailView.onAppear")
            
            // assign the order to the model.
            self.orderModel = .init(order: self.order)
            
//            // set block to assign customer to order when a customer is selected
//            self.orderModel.willSetCustomerURI = { uri in
//                guard let context = self.order.managedObjectContext else { return }
//                if uri == OrderForm.Model.customerURINone {
//                    self.order.customer = nil
//                } else {
//                    self.order.customer = self.customerDataSource.object(forURI: uri, in: context)
//                }
//            }
        }
    }
}


fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()


#if DEBUG
struct OrderRow_Previews : PreviewProvider {
    static let cud = CUDDataSource<Order>(context: CoreDataStack.current.mainContext)
    static let order = Order(context: cud.sourceContext)
    static var previews: some View {
        OrderRow(order: order, onSave: { _ in })
    }
}
#endif
