//
//  SaleItemDataSource.swift
//  ShoB
//
//  Created by Dara Beng on 8/10/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


class SaleItemDataSource: NSObject, DataSource {
    
    let parentContext: NSManagedObjectContext
    
    let createContext: NSManagedObjectContext
    
    let updateContext: NSManagedObjectContext
    
    let fetchedResult: NSFetchedResultsController<SaleItem>
    
    var newObject: SaleItem?
    
    var updateObject: SaleItem?
    
    
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
        guard let saleItem = newObject, saleItem.hasValidInputs() else { return }
        saveCreateContext()
    }
    
    func saveUpdateObject() {
        guard let saleItem = updateObject, saleItem.hasValidInputs() else { return }
        saleItem.objectWillChange.send() // still need this (beta 5)
        
        if saleItem.hasPersistentChangedValues {
            saveUpdateContext()
        } else {
            discardUpdateContext()
        }
    }
}
