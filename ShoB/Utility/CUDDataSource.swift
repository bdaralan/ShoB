//
//  CUDDataSource.swift
//  ShoB
//
//  Created by Dara Beng on 7/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData
import SwiftUI
import Combine


/// A data source use to create, update, or delete object.
class CUDDataSource<T: NSManagedObject>: BindableObject {
    
    let didChange = PassthroughSubject<CUDDataSource, Never>()
    
    /// The source context.
    let sourceContext: NSManagedObjectContext
    
    /// The context used to place new order.
    let createContext: NSManagedObjectContext
    
    /// The context used to view or edit existing orders.
    let updateContext: NSManagedObjectContext
    
    /// A new order to be placed.
    private var newObjectToCreate: T?
    
    /// The new order to be placed.
    ///
    /// Return a new order after `cancelPlacingNewOrder()` or `placeNewOrder()` is called.
    var newObject: T {
        if newObjectToCreate == nil {
            newObjectToCreate = T(context: createContext)
        }
        return newObjectToCreate!
    }
    
    
    /// Construct the data source with the given context.
    /// - Parameter context: The parent or source context.
    init(context: NSManagedObjectContext) {
        sourceContext = context
        createContext = sourceContext.newChildContext()
        updateContext = sourceContext.newChildContext()
    }
    
    
    /// Save the `newOrder` to the context.
    func saveNewObject() {
        guard newObjectToCreate?.managedObjectContext == createContext else { return }
        createContext.quickSave()
        sourceContext.quickSave()
        newObjectToCreate = nil
    }
    
    /// Discard the `newOrder` that hasn't been placed from the context.
    func discardNewObject() {
        createContext.rollback()
        newObjectToCreate = nil
    }
    
    /// Save changes of the order to the context.
    ///
    /// - Parameter order: The order to update. This order must be in the `viewOrderContext`.
    func updateObject(_ object: T) {
        guard object.managedObjectContext == updateContext else { return }
        guard object.hasPersistentChangedValues else { return }
        updateContext.quickSave()
        sourceContext.quickSave()
    }
}
