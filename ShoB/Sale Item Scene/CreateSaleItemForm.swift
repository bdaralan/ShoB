//
//  CreateSaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct CreateSaleItemForm : View {
    
    /// The model to create sale item.
    @Binding var model: SaleItemForm.Model
    
    /// Triggered when the item is saved.
    var onCreate: () -> Void
    
    /// Triggered when cancelled to create a new item.
    var onCancel: () -> Void
    
    
    var body: some View {
        SaleItemForm(model: $model, showQuantity: false)
            .navigationBarTitle("New Item", displayMode: .inline)
            .navigationBarItems(leading: cancelAddingNewSaleItemNavItem, trailing: addNewSaleItemNavItem)
    }
    
    
    var cancelAddingNewSaleItemNavItem: some View {
        Button("Cancel", action: onCancel)
    }
    
    var addNewSaleItemNavItem: some View {
        Button("Add", action: onCreate)
            .font(Font.body.bold())
    }
}

#if DEBUG
struct AddSaleItemView_Previews : PreviewProvider {
    static let cud = CUDDataSource<SaleItem>(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CreateSaleItemForm(model: .constant(.init()), onCreate: {}, onCancel: {})
    }
}
#endif
