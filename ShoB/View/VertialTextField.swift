//
//  InputField.swift
//  ShoB
//
//  Created by Dara Beng on 7/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A text field with a description label below it.
struct VertialTextField: View {
    
    /// The binding text for the text field.
    @Binding var text: String
    
    /// The label describing the text field.
    var label: String
    
    /// The placeholder for the text field.
    /// If `nil`, the label is used.
    var placeholder: String?
    
    var textContentType: UITextContentType?
    
    
    init(_ label: String, placeholder: String? = nil, text: Binding<String>, content: UITextContentType? = nil) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.textContentType = content
    }
    
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder ?? label, text: $text)
                .multilineTextAlignment(.leading)
                .padding(.top, Self.topPadding)
                .textContentType(textContentType)
            Text(label)
                .font(.caption)
                .foregroundColor(Self.labelColor)
        }
    }
}


extension VertialTextField {
    
    static let topPadding: CGFloat = 4
    
    static let labelColor: Color = .secondary
}


#if DEBUG
struct InputField_Previews: PreviewProvider {
    static var previews: some View {
        VertialTextField("Label", placeholder: "Placeholder", text: .constant(""))
    }
}
#endif
