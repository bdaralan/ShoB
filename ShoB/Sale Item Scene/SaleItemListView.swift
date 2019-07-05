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
    
    @State var isAddingNewSaleItem = false
    
    /// Action to perform when an item is selected.
    ///
    /// Set this block to do custom action.
    /// Otherwise, The view will show the item details.
    var onItemSelected: ((SaleItem, SaleItemListView) -> Void)?
    
    
    var body: some View {
        List(saleItemDataSource.fetchController.fetchedObjects ?? []) { saleItem in
            if self.onItemSelected == nil { // default behavior, show item details
                SaleItemRow(saleItem: saleItem.get(from: self.cudDataSource.updateContext), onUpdate: { saleItem in
                    self.cudDataSource.updateObject(saleItem)
                })
            } else { // custom behavior
                Button(saleItem.name, action: { self.onItemSelected?(saleItem, self) })
            }
        }
        .navigationBarItems(trailing: addNewSaleItemNavItem)
        .presentation(isAddingNewSaleItem ? addSaleItemForm : nil)
    }
    

    var addNewSaleItemNavItem: some View {
        Button(action: {
            self.isAddingNewSaleItem = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        }).accentColor(.accentColor)
    }
    
    var addSaleItemForm: Modal {
        let cancelAdding = {
            self.cudDataSource.discardNewObject()
            self.isAddingNewSaleItem = false
        }
        
        let addSaleItem = {
            self.cudDataSource.saveNewObject()
            self.isAddingNewSaleItem = false
        }
        
        let addSaleItemForm = CreateSaleItemForm(
            newSaleItem: cudDataSource.newObject,
            onCancel: cancelAdding,
            onAdd: addSaleItem
        )
        
        return Modal(addSaleItemForm, onDismiss: { self.isAddingNewSaleItem = false })
    }
}

#if DEBUG
struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemListView()
    }
}
#endif
