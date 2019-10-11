//
//  ModalInputField.swift
//  ShoB
//
//  Created by Dara Beng on 10/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct ModalInputField: View {
    
    /// The input field mode.
    var mode: InputMode
    
    /// The input field text.
    @Binding var text: String
    
    /// A flag to show or hide the keyboard.
    @Binding var isActive: Bool
    
    /// A short title for the modal.
    var prompt: String
    
    /// A placeholder for the text field.
    var placeholder = ""
    
    /// A text description under the text field.
    var description = ""
    
    /// A color for the description.
    var descriptionColor = Color.secondary
    
    /// A title for the done button.
    var done = "Done"
    
    var keyboard = UIKeyboardType.default
    
    var returnKey = UIReturnKeyType.default
    
    /// An action to perform when the done button is tapped.
    var onDone: (() -> Void)?
    
    /// An action to perform when the keyboard ended editing.
    var onEditingEnd: (() -> Void)?
    
    
    var body: some View {
        VStack {
            HStack {
                Text(prompt)
                    .font(Font.title.bold())
                Spacer()
                Button(action: commitEditing) {
                    Text(done).bold()
                }
            }
            inputField
            Text(description)
                .font(.callout)
                .multilineTextAlignment(.leading)
                .foregroundColor(descriptionColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                .hidden(mode != .textfield)
            Spacer()
        }
        .padding(24)
    }
}


extension ModalInputField {
    
    var inputField: some View {
        switch mode {
        case .textfield: return textField.eraseToAnyView()
        case .textview: return textView.eraseToAnyView()
        }
    }
    
    var textField: some View {
        VStack {
            TextFieldWrapper(
                text: $text,
                isFirstResponder: $isActive,
                placeholder: placeholder,
                onEditingEnd: onEditingEnd,
                configure: configureTextField
            )
            Divider()
        }
        .frame(height: 44, alignment: .bottom)
        .padding(.top)
    }
    
    var textView: some View {
        TextViewWrapper(
            text: $text,
            isFirstResponder: $isActive,
            onEditingEnd: onEditingEnd,
            configure: configureTextView
        )
    }
}


extension ModalInputField {
    
    func commitEditing() {
        text = text.trimmed()
        isActive = false
        onDone?()
    }
    
    func configureTextField(_ coordinator: TextFieldWrapper.Coordinator) {
        let textField = coordinator.textField
        textField.clearButtonMode = .always
        textField.font = .preferredFont(forTextStyle: .title2)
        textField.keyboardType = keyboard
        textField.returnKeyType = returnKey
    }
    
    func configureTextView(_ coordinator: TextViewWrapper.Coordinator) {
        let textView = coordinator.textView
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.keyboardType = keyboard
        textView.returnKeyType = returnKey
        coordinator.setupKeyboardNotification(true)
    }
    
    enum InputMode {
        case textfield
        case textview
    }
}


struct ModalTextField_Previews: PreviewProvider {
    static var previews: some View {
        ModalInputField(mode: .textfield, text: .constant("Text"), isActive: .constant(false), prompt: "Prompt")
    }
}
