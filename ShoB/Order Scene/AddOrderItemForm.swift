//
//  AddOrderItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 8/1/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct AddOrderItemForm: View {
    
    @Binding var orderItemModel: SaleItemForm.Model
    
    var saleItems: [SaleItem]
  
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // Input Section
            Section(header: Text.topSection("ORDER ITEM")) {
                SaleItemForm.BodyView(model: self.$orderItemModel, mode: .orderItem)
            }
            
            // Sale Item List Section
            Section(header: Text("ALL SALE ITEMS")) {
                ForEach(saleItems) { item in
                    Button(action: {
                        self.orderItemModel = .init(item: item, keepReference: false)
                    }, label: {
                        HStack {
                            Text("\(item.name)")
                            Spacer()
                            Text(verbatim: "\(Currency(item.price))")
                        }
                    })
                        .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}


#if DEBUG
struct AddOrderItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddOrderItemForm(orderItemModel: .constant(.init()), saleItems: [])
    }
}
#endif
