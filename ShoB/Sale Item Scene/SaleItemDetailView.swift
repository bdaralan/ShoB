//
//  SaleItemDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct SaleItemDetailView: View {
    
    @ObjectBinding var saleItem: SaleItem
    
    /// Get called after `saleItem`'s context is saved.
    ///
    /// This triggers when the update button is tapped.
    var onUpdated: () -> Void
    
    
    var body: some View {
        NavigationView {
            SaleItemForm(saleItem: saleItem)
        }
        .navigationBarTitle("Item Details", displayMode: .inline)
        .navigationBarItems(trailing: updateSaleItemNavItem)
    }
    
    
    var updateSaleItemNavItem: some View {
        Button("Update", action: {
            self.saleItem.managedObjectContext!.quickSave() // context must not be nil
            self.saleItem.didChange.send() // call to refresh the button enabled state
            self.onUpdated()
        })
        .font(Font.body.bold())
        .disabled(!saleItem.hasPersistentChangedValues)
    }
}

#if DEBUG
struct SaleItemDetailView_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemDetailView(saleItem: SaleItem(context: CoreDataStack.current.mainContext), onUpdated: {})
    }
}
#endif
