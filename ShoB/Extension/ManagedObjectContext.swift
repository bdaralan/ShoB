//
//  ManagedObjectContext.swift
//  ShoB
//
//  Created by Dara Beng on 6/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


extension NSManagedObjectContext {
    
    /// Create a child context and set itself as the parent.
    func newChildContext(type: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType, mergesChangesFromParent: Bool = false) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: type)
        context.parent = self
        context.automaticallyMergesChangesFromParent = mergesChangesFromParent
        return context
    }
    
    /// Quickly save the context by assuming that the throw will not happen.
    func quickSave() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            fatalError("failed to save context with error: \(error)")
        }
    }
}


extension NSManagedObject {
    
    /// Get the object from another context using it `objectID`.
    func get(from context: NSManagedObjectContext) -> Self {
        context.object(with: objectID) as! Self
    }
}
