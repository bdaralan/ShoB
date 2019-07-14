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
    
    var priceText: Binding<String> {
        .init(
            getValue: { self.saleItem.price == 0 ? "" : "\(Currency(self.saleItem.price))" },
            setValue: { self.saleItem.price = Currency.parseCent(from: $0) }
        )
    }
    
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name")
                    TextField("Name", text: $saleItem.name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Price")
                    TextField("$0.00", text: priceText)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

#if DEBUG
struct SaleItemForm_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemForm(saleItem: SaleItem(context: CoreDataStack.current.mainContext))
    }
}
#endif
