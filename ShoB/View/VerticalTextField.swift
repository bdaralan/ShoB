//
//  VerticalTextField.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A text field with a description label below it.
struct VerticalTextField: View {
    
    /// The binding text for the text field.
    @Binding var text: String
    
    /// The label describing the text field.
    var label: String
    
    /// The placeholder for the text field.
    /// If `nil`, the label is used.
    var placeholder: String?
    
    var content: UITextContentType?
    
    var onEditingChanged: ((Bool) -> Void)?
    
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder ?? label, text: $text, onEditingChanged: onEditingChanged ?? { _ in })
                .multilineTextAlignment(.leading)
                .padding(.top, Self.topPadding)
                .textContentType(content)
            Text(label)
                .font(.caption)
                .foregroundColor(Self.labelColor)
        }
    }
}


extension VerticalTextField {
    
    static let topPadding: CGFloat = 4
    
    static let labelColor: Color = .secondary
}


struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        VerticalTextField(text: .constant("Text"), label: "label", placeholder: "placeholder", content: nil, onEditingChanged: nil)
    }
}
