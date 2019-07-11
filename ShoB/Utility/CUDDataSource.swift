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
    
    /// A new object to be created.
    ///
    /// To set a new object, call `prepareNewObject()`.
    ///
    /// The object becomes `nil` after calling:
    ///
    /// - `saveNewObject()`
    /// - `discardNewObject()`
    ///
    /// See the above methods for more details.
    private(set) var newObject: T?
    
    
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
        guard createContext.hasChanges else { return }
        newObject = nil
        createContext.quickSave()
        sourceContext.quickSave()
        didChange.send()
    }
    
    /// Discard the `newObject` that hasn't been created.
    /// This also reset the `createContext` back to its previous commit state.
    func discardNewObject() {
        guard createContext.hasChanges else { return }
        newObject = nil
        createContext.rollback()
        didChange.send()
    }
    
    /// Create a new object and assign to `newObject`.
    ///
    /// The method only creates a new object if `newObject` is `nil`.
    func prepareNewObject() {
        guard newObject == nil else { return }
        newObject = T(context: createContext)
        didChange.send()
    }
    
    /// Save changes from `updateContext` to `sourceContext`.
    func saveUpdateContext() {
        updateContext.quickSave()
        sourceContext.quickSave()
        didChange.send()
    }
    
    /// Discard changes from `updateContext`.
    func discardUpdateContext() {
        updateContext.rollback()
        didChange.send()
    }
}
