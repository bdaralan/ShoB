//
//  AnyView.swift
//  ShoB
//
//  Created by Dara Beng on 7/26/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension AnyView {
    
    static var emptyView: AnyView {
        AnyView(EmptyView())
    }
}


extension View {
    
    /// Flat view to `AnyView`.
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func hidden(_ hidden: Bool) -> some View {
        hidden ? AnyView(EmptyView()) : AnyView(self)
    }
}
