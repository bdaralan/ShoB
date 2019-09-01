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
    
    func saveNewObject() {
        guard let store = newObject else { return }
        guard !store.name.isEmpty else { return }
        saveCreateContext()
    }
    
    func saveUpdateObject() {
        guard let store = updateObject else { return }
        store.objectWillChange.send() // still need in beta 7
        
        if store.hasPersistentChangedValues, store.hasValidInputs() {
            saveUpdateContext()
        } else {
            discardUpdateContext()
        }
    }
}
