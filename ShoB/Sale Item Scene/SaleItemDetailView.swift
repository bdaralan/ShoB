//
//  SaleItemDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct SaleItemDetailView: View {
    
    /// The item to view or update.
    @ObjectBinding var saleItem: SaleItem
    
    /// Triggered when the item is updated.
    var onUpdated: () -> Void
    
    
    var body: some View {
        SaleItemForm(model: .constant(.init()), showQuantity: false)
            .navigationBarTitle("Item Details", displayMode: .inline)
            .navigationBarItems(trailing: updateSaleItemNavItem)
    }
    
    
    var updateSaleItemNavItem: some View {
        Button("Update", action: {
            self.saleItem.managedObjectContext!.quickSave()
            self.saleItem.willChange.send() // reload enabled state
            self.onUpdated()
            
        })
        .font(Font.body.bold())
        .disabled(!saleItem.hasPersistentChangedValues)
    }
}

#if DEBUG
struct SaleItemDetailView_Previews : PreviewProvider {
    static let item = SaleItem(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        SaleItemDetailView(saleItem: item, onUpdated: {})
    }
}
#endif
