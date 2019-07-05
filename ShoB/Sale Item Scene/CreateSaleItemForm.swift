//
//  CreateSaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct CreateSaleItemForm : View {
    
    @ObjectBinding var newSaleItem: SaleItem
    
    var onCancel: () -> Void
    
    var onAdd: () -> Void
    
    
    var body: some View {
        SaleItemForm(saleItem: newSaleItem)
            .navigationBarTitle("New Item", displayMode: .inline)
            .navigationBarItems(leading: cancelAddingNewSaleItemNavItem, trailing: addNewSaleItemNavItem)
    }
    
    
    var cancelAddingNewSaleItemNavItem: some View {
        Button("Cancel", action: onCancel)
    }
    
    var addNewSaleItemNavItem: some View {
        Button("Add", action: onAdd)
    }
}

#if DEBUG
struct AddSaleItemView_Previews : PreviewProvider {
    static var previews: some View {
        CreateSaleItemForm(newSaleItem: SaleItem(context: CoreDataStack.current.mainContext), onCancel: {}, onAdd: {})
    }
}
#endif
