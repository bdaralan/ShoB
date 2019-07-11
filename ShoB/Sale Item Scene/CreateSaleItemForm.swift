//
//  CreateSaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct CreateSaleItemForm : View {
    
    @EnvironmentObject var cudDataSource: CUDDataSource<SaleItem>
    
    var onCreated: () -> Void
    
    var onCancelled: () -> Void
    
    
    var body: some View {
        SaleItemForm(saleItem: cudDataSource.newObject!)
            .navigationBarTitle("New Item", displayMode: .inline)
            .navigationBarItems(leading: cancelAddingNewSaleItemNavItem, trailing: addNewSaleItemNavItem)
    }
    
    
    var cancelAddingNewSaleItemNavItem: some View {
        Button("Cancel", action: {
            self.cudDataSource.discardNewObject()
            self.cudDataSource.prepareNewObject()
            self.onCancelled()
        })
    }
    
    var addNewSaleItemNavItem: some View {
        Button("Add", action: {
            self.cudDataSource.saveNewObject()
            self.cudDataSource.prepareNewObject()
            self.onCreated()
        })
        .font(Font.body.bold())
    }
}

#if DEBUG
struct AddSaleItemView_Previews : PreviewProvider {
    static var previews: some View {
        CreateSaleItemForm(onCreated: {}, onCancelled: {})
    }
}
#endif
