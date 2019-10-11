//
//  TextFieldWrapper.swift
//  ShoB
//
//  Created by Dara Beng on 10/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct TextFieldWrapper: UIViewRepresentable {
    
    @Binding var text: String
    
    @Binding var isFirstResponder: Bool
    
    var placeholder: String
    
    var onEditingEnd: (() -> Void)?
    
    var configure: ((Coordinator) -> Void)?
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let coordinator = context.coordinator
        configure?(coordinator)
        return coordinator.textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder
        
        // handle show or hide keyboard
        if uiView.window != nil {
            if isFirstResponder {
                if !uiView.isFirstResponder {
                    uiView.becomeFirstResponder()
                }
            } else {
                uiView.resignFirstResponder()
            }
        }
    }
    
    
    // MARK: Coordinator
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        let wrapper: TextFieldWrapper
        
        let textField = UITextField()
        
        
        init(wrapper: TextFieldWrapper) {
            self.wrapper = wrapper
            
            super.init()
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        }
        
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            wrapper.isFirstResponder = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            wrapper.isFirstResponder = false
            wrapper.onEditingEnd?()
        }
        
        @objc private func textFieldChanged(_ sender: UITextField) {
            wrapper.text = sender.text ?? ""
        }
    }
}
