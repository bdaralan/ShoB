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
    
    func saveNewObject() {
        guard let order = newObject, order.hasValidInputs() else { return }
        saveCreateContext()
    }
    
    func saveUpdateObject() {
        guard let order = updateObject, order.hasValidInputs() else { return }
        order.objectWillChange.send() // still need this (beta 5)
        
        if order.hasPersistentChangedValues || order.isMarkedValuesChanged {
            order.isMarkedValuesChanged = false
            saveUpdateContext()
        } else {
            discardUpdateContext()
        }
    }
}
