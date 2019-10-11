//
//  ModalTextView.swift
//  ShoB
//
//  Created by Dara Beng on 10/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct ModalTextView: View {
    
    /// The text view text.
    @Binding var text: String
    
    /// A bool to show or hide keyboard.
    @Binding var isActive: Bool
    
    var prompt: String
    
    var onDone: (() -> Void)?
    
    var onEditingEnd: (() -> Void)?
    
    
    var body: some View {
        VStack {
            HStack {
                Text(prompt)
                    .font(Font.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button(action: commitEditing) {
                    Text("Done").bold()
                }
            }
            TextViewWrapper(
                text: $text,
                isFirstResponder: $isActive,
                onEditingEnd: onEditingEnd,
                configure: configureTextView
            )
        }
        .padding(24)
    }
}


extension ModalTextView {
    
    func commitEditing() {
        text = text.trimmed()
        isActive = false
        onDone?()
    }
    
    func configureTextView(_ coordinator: TextViewWrapper.Coordinator) {
        let textView = coordinator.textView
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        coordinator.setupKeyboardNotification(true)
    }
}


struct ModalTextView_Previews: PreviewProvider {
    static var previews: some View {
        ModalTextView(text: .constant("Hello"), isActive: .constant(false), prompt: "Prompt")
    }
}
