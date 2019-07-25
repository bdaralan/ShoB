//
//  String.swift
//  ShoB
//
//  Created by Dara Beng on 7/25/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension String {
    
    func replaceEmpty(with replacement: String) -> String {
        return isEmpty ? replacement : self
    }
}
