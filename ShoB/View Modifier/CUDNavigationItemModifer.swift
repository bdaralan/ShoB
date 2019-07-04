//
//  CUDNavigationItemModifer.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct CUDNavigationItemModifer: ViewModifier {
    
    let commitTitle: String
    
    let enableCommit: Bool
    
    let onCommit: () -> Void
    
    let onCancel: (() -> Void)?
    
    
    func body(content: Content) -> some View {
        if onCancel == nil {
            return content.navigationBarItems(leading: cancelNavItem, trailing: commitNavItem)
        } else {
            return content.navigationBarItems(leading: cancelNavItem, trailing: commitNavItem)
        }
    }
    
    
    var cancelNavItem: some View {
        Button(action: onCancel ?? {}, label: { Text("Cancel") })
    }
    
    var commitNavItem: some View {
        Button(action: onCommit, label: { Text(commitTitle) }).disabled(!enableCommit)
    }
}
