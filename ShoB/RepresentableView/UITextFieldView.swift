//
//  UITextFieldView.swift
//  ShoB
//
//  Created by Dara Beng on 6/30/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct UITextFieldView : UIViewRepresentable {
    
    @Binding var text: String
    
    var setup: ((UITextField) -> Void)?
    
    var showToolBar: Bool = false
    
    var onEditingChanged: ((UITextField) -> Void)?
    
    
    func makeCoordinator() -> UITextFieldView.Coordinator {
        return Coordinator(text: $text, onEditingChanged: onEditingChanged)
    }
    
    func makeUIView(context: UIViewRepresentableContext<UITextFieldView>) -> UITextField {
        let textField = UITextField()
        let coordinator = context.coordinator
        textField.delegate = coordinator
        textField.addTarget(coordinator, action: #selector(Coordinator.textFieldTextChanged), for: .editingChanged)
        
        setup?(textField)
        
        if showToolBar {
            let toolBar = UIToolbar(frame: .init(x: 0, y: 0, width: 0, height: 45))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(title: "Done", style: .done, target: textField, action: #selector(textField.resignFirstResponder))
            toolBar.items = [spacer, done]
            textField.inputAccessoryView = toolBar
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<UITextFieldView>) {
        uiView.text = text
    }
    
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        
        var onEditingChanged: ((UITextField) -> Void)?
        

        init(text: Binding<String>, onEditingChanged: ((UITextField) -> Void)?) {
            self.$text = text
            self.onEditingChanged = onEditingChanged
        }
        
        
        @objc func textFieldTextChanged(_ sender: UITextField) {
            onEditingChanged?(sender)
            text = sender.text ?? ""
        }
    }
}
