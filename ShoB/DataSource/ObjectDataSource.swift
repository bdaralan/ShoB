//
//  ObjectDataSource.swift
//  ShoB
//
//  Created by Dara Beng on 7/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData
import Combine


/// A data source protocol for creating, reading, updating, and deleting object.
protocol ObjectDataSource: NSFetchedResultsControllerDelegate, ObservableObject {
    
    /// The type of object that the data source will work with.
    associatedtype Object: NSManagedObject & ObjectValidatable
    
    /// - Parameter parentContext: The parent context.
    init(parentContext: NSManagedObjectContext)
        
    /// The source context.
    var parentContext: NSManagedObjectContext { get }
    
    /// The context used to create new object.
    var createContext: NSManagedObjectContext { get }
    
    /// The context used to read and update existing object.
    var updateContext: NSManagedObjectContext { get }
    
    /// Fetch result controller.
    var fetchedResult: NSFetchedResultsController<Object> { set get }
    
    /// A new object to be created.
    ///
    /// - This object is `nil` until `prepareNewObject()` is called.
    /// - Call `discardNewObject()` to set it to `nil`.
    var newObject: Object? { set get }
    
    /// An object to update. It must be from the `updateContext`.
    var updateObject: Object? { set get }
    
    /// Save `newObject` to its context.
    func saveNewObject() -> ObjectDataSourceSaveResult
    
    /// Save changes of the `updateObject` to its context.
    func saveUpdateObject() -> ObjectDataSourceSaveResult
}


// MARK: - Save Result Enum

enum ObjectDataSourceSaveResult {
    case saved
    case failed
    case unchanged
}


// MARK: - Default Save & Update

extension ObjectDataSource {
    
    func saveNewObject() -> ObjectDataSourceSaveResult {
        guard let object = newObject, object.isValid() else { return .failed }
        saveCreateContext()
        return .saved
    }
    
    func saveUpdateObject() -> ObjectDataSourceSaveResult {
        guard let object = updateObject, object.isValid() else { return .failed }
        object.objectWillChange.send()
        if object.hasChangedValues() {
            saveUpdateContext()
            return .saved
        } else {
            discardUpdateContext()
            return .unchanged
        }
    }
}


// MARK: - Fetch Method

extension ObjectDataSource {
    
    /// Perform fetch on the `fetchController`.
    /// - Parameter request: The request to perform or `nil` to perform the current request.
    func performFetch(_ request: NSFetchRequest<Object>? = nil) {
        if let request = request {
            fetchedResult.fetchRequest.predicate = request.predicate
            fetchedResult.fetchRequest.sortDescriptors = request.sortDescriptors
        }
        
        do {
            try fetchedResult.performFetch()
        } catch {
            print(error)
        }
    }
    
    /// Set fetch controller section key path.
    ///
    /// - Parameter keyPath: The key path to set.
    func setFetchResultSectionKeyPath(_ keyPath: String?) {
        let request = fetchedResult.fetchRequest
        let context = fetchedResult.managedObjectContext
        fetchedResult = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: keyPath,
            cacheName: nil
        )
        fetchedResult.delegate = self
    }
}


// MARK: Object Method

extension ObjectDataSource {
    
    /// Set `newObject` to `nil`.
    func discardNewObject() {
        guard newObject != nil else { return }
        newObject = nil
    }
    
    /// Assign `newObject` a new value if it is `nil`.
    func prepareNewObject() {
        guard newObject == nil else { return }
        newObject = Object(context: createContext)
    }
    
    /// Assign object to the `updateObject`
    /// - Parameter object: The object to assign. It must be from the `updateContext`.
    func setUpdateObject(_ object: Object?) {
        if let object = object, object.managedObjectContext === updateContext {
            updateObject = object
        } else {
            updateObject = nil
        }
    }
    
    /// Get the same object from `updateContext`.
    /// - Parameter object: The object to read.
    func readObject(_ object: Object) -> Object {
        updateContext.object(with: object.objectID) as! Object
    }
    
    /// Delete object's from the context
    /// - Parameter object: The object to delete. Must be in `parentContext` or `updateContext`.
    /// - Parameter saveContext: `true` to save the context.
    func delete(_ object: Object, saveContext: Bool) {
        guard let context = object.managedObjectContext else { return }
        guard context === parentContext || context === updateContext else { return }
        context.delete(object)
        
        guard saveContext else { return }
        context.quickSave()
        
        guard context === updateContext else { return }
        parentContext.quickSave()
    }
}


// MARK: Context Method

extension ObjectDataSource {
    
    func saveCreateContext() {
        saveContext(createContext)
    }
    
    func discardCreateContext() {
        discardContext(createContext)
    }
    
    func saveUpdateContext() {
        saveContext(updateContext)
    }
    
    func discardUpdateContext() {
        discardContext(updateContext)
    }
    
    /// Save changes of the given context.
    /// - Parameter context: Must be the `createContext` or `updateContext`.
    private func saveContext(_ context: NSManagedObjectContext) {
        guard context === createContext || context === updateContext else { return }
        guard context.hasChanges else { return }
        context.quickSave()
        parentContext.quickSave()
    }
    
    /// Discard changes of the given context.
    /// - Parameter context: Must be the `createContext` or `updateContext`.
    private func discardContext(_ context: NSManagedObjectContext) {
        guard context === createContext || context === updateContext else { return }
        guard context.hasChanges else { return }
        context.rollback()
    }
}
