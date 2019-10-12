//
//  CurrencyTextField.swift
//  ShoB
//
//  Created by Dara Beng on 8/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import UIKit


struct UIRTextField: UIViewRepresentable {
    
    @Binding var text: String
    
    var enableToolBar: Bool = false
    
    var onEditingBegan: ((UITextField) -> Void)?
    
    var onEditingChanged: ((String) -> Void)?
    
    var onEditingEnded: ((String) -> Void)?
    
    var textFormat: ((String) -> String)?
    
    var configure: ((UITextField) -> Void)?
    
    
    // MARK: Make & Create
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = context.coordinator.textField
        configure?(textField)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    
    // MARK: Coordinator
    
    class Coordinator: NSObject {
        
        let wrapper: UIRTextField
        
        let textField = UITextField()
        
        
        init(wrapper: UIRTextField) {
            self.wrapper = wrapper
            
            super.init()
            textField.addTarget(self, action: #selector(textFieldBegan), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
            textField.addTarget(self, action: #selector(textFieldEnd), for: .editingDidEnd)
            
            if wrapper.enableToolBar {
                configureAccessoryView(for: textField)
            }
        }
        
        
        @objc func textFieldChanged(_ sender: UITextField) {
            let text = wrapper.textFormat?(sender.text!) ?? sender.text!
            sender.text = text
            wrapper.$text.wrappedValue = text
            wrapper.onEditingChanged?(text)
        }
        
        @objc func textFieldEnd(_ sender: UITextField) {
            wrapper.onEditingEnded?(sender.text!)
        }
        
        @objc func textFieldBegan(_ sender: UITextField) {
            wrapper.onEditingBegan?(sender)
        }
        
        private func configureAccessoryView(for textField: UITextField) {
            let toolBar = UIToolbar(frame: .init(x: 0, y: 0, width: 0, height: 44))
            
            toolBar.items = [
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                .init(barButtonSystemItem: .done, target: textField, action: #selector(textField.resignFirstResponder))
            ]
            
            textField.inputAccessoryView = toolBar
        }
    }
}
