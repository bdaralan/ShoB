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
                // MARK: Customer & Note
                HStack {
                    Image(systemName: "person.crop.circle")
                    Text("\(order.customer?.identity ?? "None")")
                        .foregroundColor(order.customer == nil ? .secondary : .primary)
                    if !order.note.isEmpty {
                        Spacer()
                        Image(systemName: "doc.text")
                    }
                }
                .font(.title)
                
                // MARK: Order Date
                HStack {
                    Image(systemName: "calendar")
                    Text("\(order.orderDate, formatter: dateFormatter)")
                }
                
                // MARK: Delivery Date
                HStack {
                    Image(systemName: "car.fill")
                    Text(order.deliveryDate == nil ? "No" : "\(order.deliveryDate!, formatter: dateFormatter)")
                }
                
                // MARK: Delivered Date
                HStack {
                    Image(systemName: "cube.box.fill")
                    Text(order.deliveredDate == nil ? "No" : "\(order.deliveredDate!, formatter: dateFormatter)")
                }
                
                // MARK: Total & Discount
                HStack {
                    Image(systemName: "plus.circle")
                    Text(verbatim: "\(Currency(order.total))")
                    spacerDivider
                    Image(systemName: "minus.circle")
                    Text(verbatim: "\(Currency(order.discount))")
                    spacerDivider
                    Image(systemName: "equal.circle")
                    Text(verbatim: "\(Currency(order.total - order.discount))").bold()
                }
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
        }
    }
    
    var spacerDivider: some View {
        Group {
            Spacer()
            Divider()
            Spacer()
        }
    }
}


fileprivate let dateFormatter: DateFormatter = {
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
