//
//  Importer.swift
//  ShoB
//
//  Created by Dara Beng on 7/28/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


struct Importer {
    
}


// MARK: - Managed Object Import Method
extension Importer {
    
    static func importManagedObjects<T: NSManagedObject>(_ type: T.Type, into context: NSManagedObjectContext, fromURL: URL) -> [T] {
        guard let data = try? Data(contentsOf: fromURL) else {
            print("ManagedObjectImporter failed to load resource at url \(fromURL)")
            return []
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            print("ManagedObjectImporter failed to create json from resource \(fromURL.lastPathComponent)")
            return []
        }
        
        guard let dictionary = json as? [[String: Any]] else { return [] }
        
        var objects = [T]()
        for objectDict in dictionary {
            let object = T(context: context)
            for (key, value) in objectDict {
                object.setValue(value, forKey: key)
            }
            objects.append(object)
        }
        
        return objects
    }
}


extension Importer {
    
    static func importSampleData() {
        let context = CoreDataStack.current.mainContext
        
        let store = Store(context: context)
        store.name = "Sample Store"
        store.setPrimitiveValue("sample store", forKey: #keyPath(Store.ownerID))
        
        let sampleItemUrl = Bundle.main.url(forResource: "sale-item-sample-data", withExtension: "json")!
        let items = Importer.importManagedObjects(SaleItem.self, into: context, fromURL: sampleItemUrl)
        
        for item in items {
            item.store = store
        }
        
        let sampleCustomerUrl = Bundle.main.url(forResource: "customer-sample-data", withExtension: "json")!
        let customers = Importer.importManagedObjects(Customer.self, into: context, fromURL: sampleCustomerUrl)
        
        for customer in customers {
            customer.store = store
        }
        
        context.quickSave()
        
        Store.setCurrent(store)
    }
}
