//
//  AnyView.swift
//  ShoB
//
//  Created by Dara Beng on 7/26/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension View {
    
    /// Flat view to `AnyView`.
    func toAnyView() -> AnyView {
        AnyView(self)
    }
}
