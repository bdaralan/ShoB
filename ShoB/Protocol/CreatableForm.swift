//
//  CreatableForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


protocol CreatableForm {
    
    /// Triggered when the create button is tapped.
    var onCreate: () -> Void { set get }
    
    /// Triggered when the cancel button is tapped.
    var onCancel: () -> Void { set get }
}


extension CreatableForm {
    
    func cancelNavItem(title: String = "Cancel") -> some View {
        Button(title, action: onCancel)
    }
        
    func createNavItem(title: String) -> some View {
        Button(title, action: onCreate)
            .font(Font.body.bold())
    }
}
