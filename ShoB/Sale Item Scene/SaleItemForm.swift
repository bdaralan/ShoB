//
//  SaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct SaleItemForm: View {
    
    @ObjectBinding var saleItem: SaleItem
    
    var name: Binding<String> {
        .init(
            getValue: { self.saleItem.name},
            setValue: { self.saleItem.name = $0 }
        )
    }
    
    var priceText: Binding<String> {
        .init(
            getValue: { self.textForPrice(self.saleItem.price) },
            setValue: { self.saleItem.price = Currency.parseCent(from: $0) }
        )
    }
    
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name")
                    TextField("Name", text: name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Price")
                    UIKTextField(text: priceText, setup: { textField in
                        textField.keyboardType = .numberPad
                        textField.textAlignment = .right
                        textField.placeholder = "$0.00"
                    }, showToolBar: true, onEditingChanged: { textField in
                        let text = textField.text ?? ""
                        let price = Currency.parseCent(from: text)
                        textField.text = self.textForPrice(price)
                    })
                }
            }
        }
    }
    
    
    func textForPrice(_ price: Cent) -> String {
        price == 0 ? "" : "\(Currency(price))"
    }
}

#if DEBUG
struct SaleItemForm_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemForm(saleItem: SaleItem(context: CoreDataStack.current.mainContext))
    }
}
#endif
