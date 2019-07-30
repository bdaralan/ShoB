//
//  NavigationStateHandler.swift
//  ShoB
//
//  Created by Dara Beng on 7/30/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Combine


/// A state model used to perform actions when a view is pushed to or popped from the NavigationView
///
/// Code Example:
///
///     struct DetailRow: View {
///
///         @State private var navigationState = NavigationStateHandler()
///
///         var body: some View {
///             NavigationLink(destination: detailView, isActive: $navigationState.isPushed) {
///                 Text("View Detials")
///             }
///         }
///
///         var detailView: some View {
///             // setup handler in onAppear for now
///             // until there is a better place for the setup
///             Text("Details").onAppear {
///                 navigationState.onPopped = {
///                     // grab popcorn
///                 }
///             }
///         }
///     }
///
struct NavigationStateHandler {
    
    /// A flag to bind with `NavigationLink.isActive`.
    var isPushed = false {
        didSet { state = isPushed ? .pushed : .popped }
    }
    
    /// The state of the navigation.
    private var state: State? = .none {
        didSet {
            switch state {
            case .pushed: onPushed?()
            case .popped: onPopped?()
            case .none: break
            }
        }
    }
    
    /// An action to perform when pushed.
    var onPushed: (() -> Void)?
    
    /// An action to perform when poped.
    var onPopped: (() -> Void)?
}


private extension NavigationStateHandler {
    
    enum State {
        case pushed
        case popped
    }
}
