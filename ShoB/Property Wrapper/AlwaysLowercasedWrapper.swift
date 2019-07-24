//
//  AlwaysLowercasedWrapper.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


@propertyWrapper
struct AlwaysLowercasedWrapper {
    
    var string = ""
    
    var wrappedValue: String {
        get { string }
        set { string = newValue.lowercased() }
    }
    
    
    init(initialValue: String = "") {
        wrappedValue = initialValue
    }
}
