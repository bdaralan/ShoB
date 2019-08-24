//
//  CurrencyTextField.swift
//  ShoB
//
//  Created by Dara Beng on 8/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct CurrencyTextField: View {
    
    @Binding var text: String
    
    
    // MARK: - Body
    
    var body: some View {
        UIRTextField(text: $text, enableToolBar: true, onEditingBegan: { textField in
            textField.selectAll(nil)
        }, textFormat: { text in
            "\(Currency(Currency.parseCent(from: text)))"
        }, configure: { textField in
            textField.textAlignment = .right
            textField.keyboardType = .numberPad
        })
    }
}

struct CurrencyTextField_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyTextField(text: .constant("$0.00"))
    }
}
