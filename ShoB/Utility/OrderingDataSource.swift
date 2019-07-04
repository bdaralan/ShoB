//
//  OrderingDataSource.swift
//  ShoB
//
//  Created by Dara Beng on 7/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData
import SwiftUI
import Combine


class OrderingDataSource: BindableObject {
    
    let didChange = PassthroughSubject<OrderingDataSource, Never>()
    
    /// The source context.
    let sourceContext: NSManagedObjectContext
    
    /// The context used to place new order.
    let placeOrderContext: NSManagedObjectContext
    
    /// The context used to view or edit existing orders.
    let viewOrderContext: NSManagedObjectContext
    
    /// A new order to be placed.
    private var newOrderToPlace: Order?
    
    /// The new order to be place.
    var newOrder: Order {
        if newOrderToPlace == nil {
            newOrderToPlace = Order(context: placeOrderContext)
        }
        return newOrderToPlace!
    }
    
    
    /// Construct the data source with the given context.
    /// - Parameter context: The parent or source context.
    init(context: NSManagedObjectContext) {
        sourceContext = context
        placeOrderContext = sourceContext.newChildContext()
        viewOrderContext = sourceContext.newChildContext()
    }
    
    
    /// Save the `newOrder` to the context.
    func placeNewOrder() {
        guard newOrderToPlace != nil else { return }
        placeOrderContext.quickSave()
        sourceContext.quickSave()
        newOrderToPlace = nil
    }
    
    /// Discard the `newOrder` that hasn't been placed from the context.
    func cancelPlacingNewOrder() {
        newOrderToPlace = nil
        placeOrderContext.rollback()
    }
    
    /// Save changes of the order to the context.
    ///
    /// - Parameter order: The order to update. This order must be in the `viewOrderContext`.
    func updateOrder(_ order: Order) {
        guard order.managedObjectContext == viewOrderContext else { return }
        guard order.hasPersistentChangedValues else { return }
        viewOrderContext.quickSave()
        sourceContext.quickSave()
    }
}
