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
    
    let didChange = PassthroughSubject<Void, Never>()
    
    /// The source context.
    let sourceContext: NSManagedObjectContext
    
    /// The context used to place new order.
    let createContext: NSManagedObjectContext
    
    /// The context used to view or edit existing orders.
    let updateContext: NSManagedObjectContext
    
    /// A new object to be created and saved.
    private var newObjectToCreate: T?
    
    /// A newly created object.
    ///
    /// Accessing this property will give the same object until the one of following methods is called.
    /// - `discardNewObject()`
    /// - `saveNewObject()`
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
    
    
    /// Save the `newObject` to the context.
    ///
    /// The new time the `newObject` is used, a newly created object is returned.
    func saveNewObject() {
        guard newObjectToCreate?.managedObjectContext == createContext else { return }
        newObjectToCreate = nil
        createContext.quickSave()
        sourceContext.quickSave()
        didChange.send()
    }
    
    /// Discard the `newObject` that hasn't been created.
    /// This also reset the `createContext` back to its previous commit state.
    func discardNewObject() {
        newObjectToCreate = nil
        createContext.rollback()
        didChange.send()
    }
    
    /// Save changes of the given object to the context.
    ///
    /// - Parameter object: The object that has changes and it must be from the `updateContext`.
    func updateObject(_ object: T) {
        guard object.managedObjectContext == updateContext else { return }
        updateContext.quickSave()
        sourceContext.quickSave()
        didChange.send()
    }
}
