//
//  Text.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension Text {
    
    static func topSection(_ text: String, padding: Length = 16) -> some View {
        Text(text).padding(.top, padding)
    }
}
