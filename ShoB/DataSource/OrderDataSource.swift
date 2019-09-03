//
//  OrderDataSource.swift
//  ShoB
//
//  Created by Dara Beng on 8/10/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


class OrderDataSource: NSObject, DataSource {
    
    let parentContext: NSManagedObjectContext
    
    let createContext: NSManagedObjectContext
    
    let updateContext: NSManagedObjectContext
    
    let fetchedResult: NSFetchedResultsController<Order>
    
    var newObject: Order?
    
    var updateObject: Order?
    
    
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
        guard let order = newObject, order.isValid() else { return .failed }
        saveCreateContext()
        return .saved
    }
    
    func saveUpdateObject() -> DataSourceSaveResult {
        guard let order = updateObject, order.isValid() else { return .failed }
        order.objectWillChange.send() // still need this (beta 5)
        
        if order.hasPersistentChangedValues || order.isMarkedValuesChanged {
            order.isMarkedValuesChanged = false
            saveUpdateContext()
            return .saved
        } else {
            discardUpdateContext()
            return .unchanged
        }
    }
}
