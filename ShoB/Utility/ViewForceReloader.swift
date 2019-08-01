//
//  ViewForceReloader.swift
//  ShoB
//
//  Created by Dara Beng on 8/1/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// An class used to force view to reload.
///
/// A work around for now (beta 5).
/// Use to reload list when doing manual delete row and pop off navigation view.
class ViewForceReloader: ObservableObject {
    
    /// Just a property to modify to trigger the reload
    @Published private var forceReloadCount = 0
    
    /// Call this method to force a view to reload.
    func forceReload() {
        forceReloadCount += 1
    }
}
