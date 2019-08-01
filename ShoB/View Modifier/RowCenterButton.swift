//
//  RowCenterButton.swift
//  ShoB
//
//  Created by Dara Beng on 7/31/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct RowCenterButtonStyle: ButtonStyle {
    
    let actionType: ActionType
    
    
    init(_ type: ActionType = .normal) {
        actionType = type
    }
    
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            Spacer()
            configuration.label
            Spacer()
        }
        .foregroundColor(accentColor(for: actionType))
    }
    
    func accentColor(for type: ActionType) -> Color {
        switch type {
        case .normal: return .accentColor
        case .destructive: return .red
        }
    }
    
    enum ActionType {
        case normal
        case destructive
    }
}
