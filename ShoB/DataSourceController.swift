//
//  DataSourceController.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData
import Combine


class ManagedObjectDataSource<T: NSManagedObject>: NSObject, BindableObject, NSFetchedResultsControllerDelegate {
    
    let didChange = PassthroughSubject<Void, Never>()
    
    let context: NSManagedObjectContext
    var fetchController: NSFetchedResultsController<T>!
    
    
    init(context: NSManagedObjectContext, entity: T.Type) {
        self.context = context
        self.fetchController = ManagedObjectDataSource.createFetchController(context: context, entity: entity.self)
        super.init()
        fetchController.delegate = self
    }
    
    
    func performFetch() {
        do {
            try fetchController.performFetch()
        } catch {
            print(error)
        }
        didChange.send(())
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChange.send(())
    }
}


extension ManagedObjectDataSource {
    
    static func createFetchController<T: NSManagedObject>(context: NSManagedObjectContext, entity: T.Type) -> NSFetchedResultsController<T> {
        let request = entity.fetchRequest() as! NSFetchRequest<T>
        request.sortDescriptors = []
        
        let fetchController = NSFetchedResultsController<T>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return fetchController
    }
}
