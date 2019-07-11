//
//  SaleItemListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct SaleItemListView: View {
    
    @EnvironmentObject var saleItemDataSource: FetchedDataSource<SaleItem>
    @EnvironmentObject var cudDataSource: CUDDataSource<SaleItem>
    
    @State var isAddingNewItem = false
    
    /// Action to perform when an item is selected.
    ///
    /// Set this block to do custom action.
    /// Otherwise, The view will show the item details.
    var onItemSelected: ((SaleItem, SaleItemListView) -> Void)?
    
    
    var body: some View {
        List(saleItemDataSource.fetchController.fetchedObjects ?? []) { saleItem in
            if self.onItemSelected == nil { // default behavior, show item details
                SaleItemRow(saleItem: saleItem.get(from: self.cudDataSource.updateContext), onUpdate: { saleItem in
                    self.cudDataSource.saveUpdateContext()
                    saleItem.didChange.send()
                })
            } else { // custom behavior
                Button(saleItem.name, action: { self.onItemSelected?(saleItem, self) })
            }
        }
        .navigationBarItems(trailing: addNewSaleItemNavItem)
        .presentation(isAddingNewItem ? createSaleItemForm : nil)
    }
    

    var addNewSaleItemNavItem: some View {
        Button(
            action: { self.isAddingNewItem = true },
            label: { Image(systemName: "plus").imageScale(.large) }
        )
        .accentColor(.accentColor)
    }
    
    var createSaleItemForm: Modal {
        let cancelAddItem = {
            self.cudDataSource.discardNewObject()
            self.isAddingNewItem = false
        }
        
        let addItem = {
            self.cudDataSource.saveNewObject()
            self.isAddingNewItem = false
        }
        
        let form = CreateSaleItemForm(
            newSaleItem: cudDataSource.newObject!,
            onCancel: cancelAddItem,
            onAdd: addItem
        )
        
        return Modal(NavigationView { form }, onDismiss: { self.isAddingNewItem = false })
    }
}

#if DEBUG
struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemListView()
    }
}
#endif
