//
//  Currency.swift
//  BallDonut
//
//  Created by Dara Beng on 5/29/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


let centSymbol = "¢"
let dollarSymbol = "$"


typealias Cent = Int64
typealias Dollar = Int64


struct Currency: Equatable, CustomStringConvertible {
    
    /// Total amount in cent.
    var amount: Cent
    
    /// Dollar amount.
    var dollar: Dollar {
        return amount / 100
    }
    
    /// The remaining cent after the dollar amount.
    var cent: Cent {
        return amount - dollar * 100
    }
    
    /// Check if there are any remaining cents after the dollar amount.
    var hasChanges: Bool {
        return cent > 0
    }
    
    var isNegative: Bool {
        return amount < 0
    }
    
    /// String representation. Example: $4.90
    var description: String {
        let sign = isNegative ? "-" : ""
        return "\(sign)\(dollarSymbol)\(abs(dollar)).\(String(format: "%02d", abs(cent)))"
    }
    
    
    init(_ amountInCent: Cent) {
        self.amount = amountInCent
    }
    
    /// Construct with dollar string. Example: $1.00 or 2.00.
    init(_ dollarString: String) {
        var string = dollarString
        
        if string.hasPrefix("$") {
            string.removeFirst()
        }
        
        // convert string to number
        let dollarAmount = Double(string) ?? 0
        
        // convert string into number with 2 decimal places (ex: 1.00)
        let dollarFormat = String(format: "%.02f", dollarAmount)
        
        // convert string to cent
        self.amount = Currency.parseCent(from: dollarFormat)
    }
    
    /// Parse all the digits in the string and turn them into cent.
    /// - Returns: The amount of `Cent` or 0 if no digits found.
    static func parseCent(from string: String) -> Cent {
        let cent = Cent(string.filter({ $0.isNumber })) ?? 0
        return string.hasPrefix("-") ? -cent : cent
    }
}


/// Wrap string into currency format.
///
/// Example:
///
///     @DiscountWrapper(amount: 0)
///     var discount: String // discount = $0.00
///
@propertyWrapper
struct CurrencyWrapper {
    
    var string: String
    var amount: Cent
    
    var wrappedValue: String {
        set {
            amount = Currency.parseCent(from: newValue)
            string = "\(Currency(amount))"
        }
        
        get { string }
    }
    
    
    init(amount: Cent = 0) {
        self.amount = amount
        string = amount == 0 ? "" : "\(Currency(amount))"
    }
}
