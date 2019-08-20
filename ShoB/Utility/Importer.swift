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
    
    static func importManagedObjects<T: NSManagedObject>(_ type: T.Type, into context: NSManagedObjectContext, fromURL: URL) {
        guard let data = try? Data(contentsOf: fromURL) else {
            print("ManagedObjectImporter failed to load resource at url \(fromURL)")
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            print("ManagedObjectImporter failed to create json from resource \(fromURL.lastPathComponent)")
            return
        }
        
        guard let dictionary = json as? [[String: Any]] else { return }
        
        for objectDict in dictionary {
            let object = T(context: context)
            for (key, value) in objectDict {
                object.setValue(value, forKey: key)
            }
        }
    }
}


extension Importer {
    
    static func importSampleData() {
        let context = CoreDataStack.current.mainContext
        
        let smapleItemUrl = Bundle.main.url(forResource: "sale-item-sample-data", withExtension: "json")!
        Importer.importManagedObjects(SaleItem.self, into: context, fromURL: smapleItemUrl)
        
        let sampleCustomerUrl = Bundle.main.url(forResource: "customer-sample-data", withExtension: "json")!
        Importer.importManagedObjects(Customer.self, into: context, fromURL: sampleCustomerUrl)
        
        context.quickSave()
    }
}
