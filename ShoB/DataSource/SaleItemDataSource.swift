//
//  SaleItemDataSource.swift
//  ShoB
//
//  Created by Dara Beng on 8/10/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


class SaleItemDataSource: NSObject, ObjectDataSource {
    
    let parentContext: NSManagedObjectContext
    
    let createContext: NSManagedObjectContext
    
    let updateContext: NSManagedObjectContext
    
    var fetchedResult: NSFetchedResultsController<SaleItem>
    
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
}
