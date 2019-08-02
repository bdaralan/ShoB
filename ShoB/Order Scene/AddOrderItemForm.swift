//
//  AddOrderItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 8/1/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct AddOrderItemForm: View {
    
    @Binding var orderItemModel: SaleItemFormModel
    
    var saleItems: [SaleItem]
  
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // Input Section
            Section(header: Text.topSection("ORDER ITEM")) {
                SaleItemFormBody(model: self.$orderItemModel, mode: .orderItem)
            }
            
            // Sale Item List Section
            Section(header: Text("ALL SALE ITEMS")) {
                ForEach(saleItems) { item in
                    Button(action: {
                        // only need to get values for the model
                        // do not keep reference to avoid editing the item's original values
                        self.orderItemModel = .init(saleItem: item, keepReference: false)
                    }) {
                        HStack {
                            Text("\(item.name)")
                            Spacer()
                            Text(verbatim: "\(Currency(item.price))")
                        }
                    }
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
