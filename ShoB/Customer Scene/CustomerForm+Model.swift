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
            didSet { customer?.address = address }
        }
        
        @AlwaysLowercasedWrapper
        var email = "" {
            didSet { customer?.email = email }
        }
        
        var phone = "" {
            didSet { customer?.phone = phone }
        }
        
        
        init(customer: Customer? = nil) {
            guard let customer = customer else { return }
            
            self.customer = customer
            familyName = customer.familyName
            givenName = customer.givenName
            organization = customer.organization
            address = customer.address
            email = customer.email
            phone = customer.phone
        }
    }
}
