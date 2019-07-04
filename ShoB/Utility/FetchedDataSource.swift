//
//  FetchedDataSource.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData
import Combine


class FetchedDataSource<T: NSManagedObject>: NSObject, BindableObject, NSFetchedResultsControllerDelegate {
    
    let didChange = PassthroughSubject<Void, Never>()
    
    let context: NSManagedObjectContext
    var fetchController: NSFetchedResultsController<T>
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
        let request = T.fetchRequest() as! NSFetchRequest<T>
        request.sortDescriptors = []
        
        fetchController = NSFetchedResultsController<T>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
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
