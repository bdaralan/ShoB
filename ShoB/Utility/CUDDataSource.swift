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
    
    /// Publisher
    let didChange = PassthroughSubject<Void, Never>()
    
    /// The source context.
    let sourceContext: NSManagedObjectContext
    
    /// The context used to place new order.
    let createContext: NSManagedObjectContext
    
    /// The context used to view or edit existing orders.
    let updateContext: NSManagedObjectContext
    
    /// A new object to be created.
    ///
    /// This object is `nil` until `prepareNewObject()` is called.
    /// It becomes `nil` again after `discardNewObject()` is called.
    private(set) var newObject: T?
    
    
    /// Construct the data source with the given context.
    /// - Parameter context: The parent or source context.
    init(context: NSManagedObjectContext) {
        sourceContext = context
        createContext = sourceContext.newChildContext()
        updateContext = sourceContext.newChildContext()
    }
    
    
    /// Set `newObject` to `nil`.
    func discardNewObject() {
        guard newObject != nil else { return }
        newObject = nil
    }
    
    /// Assign `newObject` a new value if it is `nil`.
    func prepareNewObject() {
        guard newObject == nil else { return }
        newObject = T(context: createContext)
    }
    
    /// Save changes of the given context.
    /// - Parameter context: Must be the `createContext` or `updateContext`.
    func saveChanges(for context: NSManagedObjectContext) {
        guard context === createContext || context === updateContext else { return }
        guard context.hasChanges else { return }
        context.quickSave()
        sourceContext.quickSave()
        didChange.send()
    }
    
    /// Discard changes of the given context.
    /// - Parameter context: Must be the `createContext` or `updateContext`.
    func discardChanges(for context: NSManagedObjectContext) {
        guard context === createContext || context === updateContext else { return }
        guard context.hasChanges else { return }
        context.rollback()
        didChange.send()
    }
}


extension CUDDataSource {
    
    func saveCreateContext() {
        saveChanges(for: createContext)
    }
    
    func discardCreateContext() {
        discardChanges(for: createContext)
    }
    
    func saveUpdateContext() {
        saveChanges(for: updateContext)
    }
    
    func discardUpdateContext() {
        discardChanges(for: updateContext)
    }
    
    func saveSourceContext() {
        saveChanges(for: sourceContext)
    }
    
    func discardSourceContext() {
        discardChanges(for: sourceContext)
    }
}
