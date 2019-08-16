//
//  InStoreObject.swift
//  ShoB
//
//  Created by Dara Beng on 8/6/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


/// A protocol for object required validation.
protocol ValidationRequired {
    
    /// Check if object is valid to save.
    func isValid() -> Bool
    
    /// Check if object has valid inputs from the user.
    func hasValidInputs() -> Bool
}
