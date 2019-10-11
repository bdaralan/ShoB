//
//  Alert.swift
//  ShoB
//
//  Created by Dara Beng on 10/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension Alert {
    
    static func createObjectWithoutCurrentStore(object: String) -> Alert {
        Alert(
            title: Text("Cannot Create \(object)"),
            message: Text("Please create or set a current store and try again."),
            dismissButton: Alert.Button.cancel(Text("Dismiss"))
        )
    }
}
