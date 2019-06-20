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
    var amountInCent: Cent
    
    /// Dollar amount.
    var dollar: Dollar {
        return amountInCent / 100
    }
    
    /// The remaining cent after the dollar amount.
    var cent: Cent {
        return amountInCent - dollar * 100
    }
    
    /// Check if there are any remaining cents after the dollar amount.
    var hasChanges: Bool {
        return cent > 0
    }
    
    var isNegativeAmount: Bool {
        return amountInCent < 0
    }
    
    /// String representation. Example: $4.90
    var description: String {
        let sign = isNegativeAmount ? "-" : ""
        return "\(sign)\(dollarSymbol)\(abs(dollar)).\(String(format: "%02d", abs(cent)))"
    }
    
    
    init(_ amountInCent: Cent) {
        self.amountInCent = amountInCent
    }
    
    /// Construct with dollar string. Example: $1.00 or 2.00.
    init(_ dollarString: String) {
        var string = dollarString
        
        if string.hasPrefix("$") {
            string.removeFirst()
        }
        
        if let double = Double(string) {
            let dollarFormat = String(format: "%.02f", double) // ex: 1.00
            let components = dollarFormat.components(separatedBy: ".")
            let dollar = Int(components[0]) ?? 0
            let cent = Int(components[1]) ?? 0
            self.amountInCent = double < 0 ? Cent(dollar * 100 - cent) : Cent(dollar * 100 + cent)
        } else {
            self.amountInCent = 0
        }
    }
    
    /// Parse all the digits in the string and turn them into cent.
    /// - Note: Negative is ignored
    /// - Returns: The amount of `Cent` or 0 if no digits found.
    static func parseCent(_ string: String) -> Cent {
        var integer = ""
        for character in string where Cent("\(character)") != nil {
            integer.append(character)
        }
        return Cent(integer) ?? 0
    }
}
