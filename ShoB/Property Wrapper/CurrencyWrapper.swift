//
//  CurrencyWrapper.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


/// Wrap string into currency format.
///
/// Example:
///
///     @DiscountWrapper(amount: 0)
///     var discount: String // discount = $0.00
///
@propertyWrapper
struct CurrencyWrapper {
    
    var string: String = ""
    var amount: Cent = 0
    
    var wrappedValue: String {
        get { string }
        set {
            amount = Currency.parseCent(from: newValue)
            string = "\(Currency(amount))"
        }
    }
    
    
    init(amount: Cent = 0) {
        wrappedValue = "\(Currency(amount))"
    }
}
