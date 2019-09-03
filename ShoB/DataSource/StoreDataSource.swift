//
//  StoreDataSource.swift
//  ShoB
//
//  Created by Dara Beng on 8/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


class StoreDataSource: NSObject, DataSource {

    var parentContext: NSManagedObjectContext
    
    var createContext: NSManagedObjectContext
    
    var updateContext: NSManagedObjectContext
    
    var fetchedResult: NSFetchedResultsController<Store>
    
    var newObject: Store?
    
    var updateObject: Store?
    
    
    required init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        createContext = parentContext.newChildContext()
        updateContext = parentContext.newChildContext()
        
        let request = Object.fetchRequest() as NSFetchRequest<Object>
        request.sortDescriptors = []
        
        fetchedResult = .init(
            fetchRequest: request,
            managedObjectContext: parentContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResult.delegate = self
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    func saveNewObject() -> DataSourceSaveResult {
        guard let store = newObject, store.isValid() else { return .failed }
        saveCreateContext()
        return .saved
    }
    
    func saveUpdateObject()  -> DataSourceSaveResult {
        guard let store = updateObject, store.isValid() else { return .failed }
        store.objectWillChange.send() // still need in beta 7
        
        if store.hasPersistentChangedValues, store.isValid() {
            saveUpdateContext()
            return .saved
        } else {
            discardUpdateContext()
            return .unchanged
        }
    }
}
