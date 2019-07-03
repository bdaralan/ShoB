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
    
    let parentContext: NSManagedObjectContext
    let placeOrderContext: NSManagedObjectContext
    let viewOrderContext: NSManagedObjectContext
    
    private var newOrderToPlace: Order?
    
    var newOrder: Order {
        if newOrderToPlace == nil {
            newOrderToPlace = Order(context: placeOrderContext)
        }
        return newOrderToPlace!
    }
    
    init() {
        parentContext = CoreDataStack.current.mainContext
        placeOrderContext = parentContext.newChildContext()
        viewOrderContext = parentContext.newChildContext()
    }
    
    func placeNewOrder() {
        guard newOrderToPlace != nil else { return }
        placeOrderContext.quickSave()
        parentContext.quickSave()
        newOrderToPlace = nil
    }
    
    func cancelPlacingNewOrder() {
        placeOrderContext.rollback()
    }
    
    func updateViewingOrder(_ order: Order) {
        guard order.managedObjectContext == viewOrderContext else { return }
        guard order.hasPersistentChangedValues else { return }
        viewOrderContext.quickSave()
        parentContext.quickSave()
    }
}
