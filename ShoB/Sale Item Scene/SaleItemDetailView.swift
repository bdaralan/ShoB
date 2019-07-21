//
//  SaleItemDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct SaleItemDetailView: View, EditableForm {
    
    @ObjectBinding var saleItem: SaleItem
    
    /// The model to view or edit sale item.
    @Binding var model: SaleItemForm.Model
    
    var onSave: () -> Void
    
    
    // MARK: - View Body
    
    var body: some View {
        SaleItemForm(model: $model, mode: .createSaleItem)
            .navigationBarTitle("Item Details", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem(title: "Update", enable: saleItem.hasPersistentChangedValues))
    }
}

#if DEBUG
struct SaleItemDetailView_Previews : PreviewProvider {
    static let saleItem = SaleItem(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        SaleItemDetailView(saleItem: saleItem, model: .constant(.init(item: saleItem)), onSave: {})
    }
}
#endif
