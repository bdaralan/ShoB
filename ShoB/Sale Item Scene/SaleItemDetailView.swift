//
//  SaleItemDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct SaleItemDetailView: View {
    
    /// The model to view or edit sale item.
    @Binding var model: SaleItemForm.Model
    
    /// Triggered when the item is updated.
    var onUpdate: () -> Void
    
    
    var body: some View {
        SaleItemForm(model: $model, showQuantity: false)
            .navigationBarTitle("Item Details", displayMode: .inline)
            .navigationBarItems(trailing: updateSaleItemNavItem)
    }
    
    
    var updateSaleItemNavItem: some View {
        Button("Update", action: onUpdate)
            .font(Font.body.bold())
    }
}

#if DEBUG
struct SaleItemDetailView_Previews : PreviewProvider {
    static let saleItem = SaleItem(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        SaleItemDetailView(model: .constant(.init(item: saleItem)), onUpdate: {})
    }
}
#endif
