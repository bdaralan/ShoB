//
//  String.swift
//  ShoB
//
//  Created by Dara Beng on 7/25/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension String {
    
    /// Get a new string the if empty.
    /// - Parameter replacement: The replacement string.
    func replaceEmpty(with replacement: String) -> String {
        return isEmpty ? replacement : self
    }
}
