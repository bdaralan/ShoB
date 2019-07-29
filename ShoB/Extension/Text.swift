//
//  Text.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension Text {
    
    /// Text for `Section`'s header with top padding. The default is 20.
    /// - Parameter text: Header text.
    /// - Parameter padding: Top padding.
    static func topSection(_ text: String, padding: CGFloat = 20) -> some View {
        Text(text).padding(.top, padding)
    }
}
