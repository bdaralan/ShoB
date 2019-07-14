//
//  CreateSaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct CreateSaleItemForm : View {
    
    /// The data source that will create and save the new item.
    @ObjectBinding var dataSource: CUDDataSource<SaleItem>
    
    /// Triggered when the item is saved.
    var onCreated: () -> Void
    
    /// Triggered when cancelled to create a new item.
    var onCancelled: () -> Void
    
    
    var body: some View {
        SaleItemForm(saleItem: dataSource.newObject!)
            .navigationBarTitle("New Item", displayMode: .inline)
            .navigationBarItems(leading: cancelAddingNewSaleItemNavItem, trailing: addNewSaleItemNavItem)
    }
    
    
    var cancelAddingNewSaleItemNavItem: some View {
        Button("Cancel", action: {
            self.dataSource.discardCreateContext()
            self.onCancelled()
        })
    }
    
    var addNewSaleItemNavItem: some View {
        Button("Add", action: {
            self.dataSource.saveCreateContext()
            self.onCreated()
        })
        .font(Font.body.bold())
    }
}

#if DEBUG
struct AddSaleItemView_Previews : PreviewProvider {
    static let cud = CUDDataSource<SaleItem>(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        CreateSaleItemForm(dataSource: cud, onCreated: {}, onCancelled: {})
    }
}
#endif
