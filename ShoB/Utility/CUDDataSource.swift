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


/// A data source with contexts used to create, update, or delete object.
class CUDDataSource<T: NSManagedObject>: ObservableObject {
    
    /// The source context.
    let sourceContext: NSManagedObjectContext
    
    /// The context used to create new object.
    let createContext: NSManagedObjectContext
    
    /// The context used to view or edit existing object.
    let updateContext: NSManagedObjectContext
    
    /// A new object to be created.
    ///
    /// - This object is `nil` until `prepareNewObject()` is called.
    /// - Call `discardNewObject()` to set it to `nil`.
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
}


// MARK: - Convenient Method

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
    
    /// Save changes of the given context.
    /// - Parameter context: Must be the `createContext` or `updateContext`.
    private func saveChanges(for context: NSManagedObjectContext) {
        guard context === createContext || context === updateContext else { return }
        guard context.hasChanges else { return }
        context.quickSave()
        sourceContext.quickSave()
    }
    
    /// Discard changes of the given context.
    /// - Parameter context: Must be the `createContext` or `updateContext`.
    private func discardChanges(for context: NSManagedObjectContext) {
        guard context === createContext || context === updateContext else { return }
        guard context.hasChanges else { return }
        context.rollback()
    }
}
