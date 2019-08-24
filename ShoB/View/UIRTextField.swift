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
    
    typealias UIViewType = UITextField
    
    typealias Coordinator = Coordiantor
    
    @Binding var text: String
    
    var enableToolBar: Bool = false
    
    var onEditingBegan: ((UITextField) -> Void)?
    
    var onEditingChanged: ((String) -> Void)?
    
    var onEditingEnded: ((String) -> Void)?
    
    var textFormat: ((String) -> String)?
    
    var configure: ((UITextField) -> Void)?
    
    
    // MARK: Make & Create
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordiantor(text: $text)
        coordinator.onEditingBegan = onEditingBegan
        coordinator.onEditingChanged = onEditingChanged
        coordinator.onEditingEnded = onEditingEnded
        coordinator.textFormat = textFormat
        return coordinator
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        
        configure?(textField)
        
        if enableToolBar {
            configureAccessoryView(for: textField)
        }
        
        let coordinator = context.coordinator
        textField.addTarget(coordinator, action: #selector(coordinator.textFieldBegan), for: .editingDidBegin)
        textField.addTarget(coordinator, action: #selector(coordinator.textFieldChanged), for: .editingChanged)
        textField.addTarget(coordinator, action: #selector(coordinator.textFieldEnd), for: .editingDidEnd)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func configureAccessoryView(for textField: UITextField) {
        let toolBar = UIToolbar(frame: .init(x: 0, y: 0, width: 0, height: 44))
        
        toolBar.items = [
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            .init(barButtonSystemItem: .done, target: textField, action: #selector(textField.resignFirstResponder))
        ]
        
        textField.inputAccessoryView = toolBar
    }
    
    
    // MARK: Coordinator
    
    class Coordiantor: NSObject {
        
        @Binding var text: String
        
        var onEditingBegan: ((UITextField) -> Void)?
        
        var onEditingChanged: ((String) -> Void)?
        
        var onEditingEnded: ((String) -> Void)?
        
        var textFormat: ((String) -> String)?
        
        
        init(text: Binding<String>) {
            _text = text
        }
        
        
        @objc func textFieldChanged(_ sender: UITextField) {
            let text = textFormat?(sender.text!) ?? sender.text!
            sender.text = text
            $text.wrappedValue = text
            onEditingChanged?(text)
        }
        
        @objc func textFieldEnd(_ sender: UITextField) {
            onEditingEnded?(sender.text!)
        }
        
        @objc func textFieldBegan(_ sender: UITextField) {
            onEditingBegan?(sender)
        }
    }
}
