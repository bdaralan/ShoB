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


/// A data source used to fetch user's object graph.
class FetchedDataSource<T: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    /// The context to work with.
    let context: NSManagedObjectContext
    
    let fetchController: NSFetchedResultsController<T>
    
    /// The create, update, delete data source.
    let cud: CUDDataSource<T>
    
    
    /// Construct data source with a context and a request.
    /// - Parameter context: The context to work with.
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
        
        cud = .init(context: context)
        
        super.init()
        fetchController.delegate = self
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    /// Perform fetch on the `fetchController`.
    /// - Parameter request: The request to perform or `nil` to perform the current request.
    func performFetch(_ request: NSFetchRequest<T>? = nil) {
        if let request = request {
            fetchController.fetchRequest.predicate = request.predicate
            fetchController.fetchRequest.sortDescriptors = request.sortDescriptors
        }
        
        objectWillChange.send()
        
        do {
            try fetchController.performFetch()
        } catch {
            print(error)
        }
    }
}
