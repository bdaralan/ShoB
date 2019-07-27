//
//  Contact+CoreDataClass.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import SwiftUI
import Combine


/// A contact infomation.
class Contact: NSManagedObject, BindableObject {
    
    let willChange = PassthroughSubject<Void, Never>()
    
    @NSManaged var address: String
    @NSManaged var email: String
    @NSManaged var phone: String
    
    @NSManaged private(set) var customer: Customer?
    @NSManaged private(set) var store: Store?
    
    /// A flag to indicate whether its property objects should send change when its value changed.
    var shouldPropertyObjectSendWillChange = false
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        address = ""
        email = ""
        phone = ""
    }
    
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        willChange.send()
        
        guard shouldPropertyObjectSendWillChange else { return }
        customer?.willChange.send()
        store?.willChange.send()
    }
}


extension Contact {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }
}
