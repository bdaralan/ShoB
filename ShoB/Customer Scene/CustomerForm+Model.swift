//
//  CustomerForm+Model.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension CustomerForm {
    
    struct Model {
        weak var customer: Customer?
        
        var familyName = "" {
            didSet { customer?.familyName = familyName }
        }
        
        var givenName = "" {
            didSet { customer?.givenName = givenName }
        }
        
        var organization = "" {
            didSet { customer?.organization = organization }
        }
        
        var address = "" {
            didSet { customer?.contact.address = address }
        }
        
        @AlwaysLowercasedWrapper
        var email = "" {
            didSet { customer?.contact.email = email }
        }
        
        var phone = "" {
            didSet { customer?.contact.phone = phone }
        }
        
        
        init(customer: Customer? = nil) {
            guard let customer = customer else { return }
            customer.contact.shouldPropertyObjectSendWillChange = true
            
            self.customer = customer
            familyName = customer.familyName
            givenName = customer.givenName
            organization = customer.organization
            address = customer.contact.address
            email = customer.contact.email
            phone = customer.contact.phone
        }
    }
}
