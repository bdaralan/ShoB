//
//  TextViewWrapper.swift
//  ShoB
//
//  Created by Dara Beng on 10/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A wrapper for `UITextView`.
struct TextViewWrapper: UIViewRepresentable {
    
    @Binding var text: String
    
    @Binding var isFirstResponder: Bool
    
    var onEditingEnd: (() -> Void)?
    
    var configure: ((Coordinator) -> Void)?
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let coordinator = context.coordinator
        let textView = coordinator.textView
        configure?(coordinator)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        
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
    
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        let wrapper: TextViewWrapper
        
        let textView = UITextView()
        
        
        init(wrapper: TextViewWrapper) {
            self.wrapper = wrapper
            
            super.init()
            textView.delegate = self
        }
        
        
        // MARK: Delegate
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            wrapper.isFirstResponder = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            wrapper.isFirstResponder = false
            wrapper.onEditingEnd?()
        }
        
        func textViewDidChange(_ textView: UITextView) {
            wrapper.text = textView.text
        }
        
        
        // MARK: Method
        
        /// Listen to keyboard notifications to adjust text view content inset.
        /// - Parameter enable: Set `true` to enable, otherwise `false`.
        func setupKeyboardNotification(_ enable: Bool) {
            let center = NotificationCenter.default
            
            guard enable else {
                center.removeObserver(self)
                return
            }
            
            let keyboardFrameChange = UIControl.keyboardWillChangeFrameNotification
            let keyboardDidHide = UIControl.keyboardDidHideNotification
            center.addObserver(self, selector: #selector(handleKeyboardFrame), name: keyboardFrameChange, object: nil)
            center.addObserver(self, selector: #selector(handleKeyboardDidHide), name: keyboardDidHide, object: nil)
        }
        
        @objc private func handleKeyboardFrame(_ notification: Notification) {
            guard let info = notification.userInfo else { return }
            guard let keyboardFrame = info["UIKeyboardFrameEndUserInfoKey"] as? CGRect else { return }
            textView.contentInset.bottom = keyboardFrame.height
            textView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
        }
        
        @objc private func handleKeyboardDidHide(_ notification: Notification) {
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let self = self else { return }
                self.textView.contentInset.bottom = 0
                self.textView.verticalScrollIndicatorInsets.bottom = 0
            }
        }
    }
}
