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
    
    @State var showCreateSaleItemForm = false
    
    /// Action to perform when an item is selected.
    ///
    /// Set this block to do custom action.
    /// Otherwise, The view will show the item details.
    var onItemSelected: ((SaleItem, SaleItemListView) -> Void)?
    
    
    var body: some View {
        List(saleItemDataSource.fetchController.fetchedObjects ?? []) { saleItem in
            if self.onItemSelected == nil { // default behavior, show item details
                SaleItemRow(saleItem: saleItem.get(from: self.cudDataSource.updateContext), onUpdate: {
                    self.cudDataSource.saveUpdateContext()
                })
            } else { // custom behavior
                Button(saleItem.name, action: { self.onItemSelected?(saleItem, self) })
            }
        }
        .navigationBarItems(trailing: addNewSaleItemNavItem)
        .presentation(modalCreateSaleItemForm)
    }
    

    var addNewSaleItemNavItem: some View {
        Button(action: {
            self.cudDataSource.discardNewObject()
            self.cudDataSource.prepareNewObject()
            self.cudDataSource.didChange.send()
            self.showCreateSaleItemForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
        .accentColor(.accentColor)
    }
    
    var modalCreateSaleItemForm: Modal? {
        guard showCreateSaleItemForm else { return nil }
        
        let cancelItem = {
            self.cudDataSource.discardCreateContext()
            self.showCreateSaleItemForm = false
        }
        
        let createItem = {
            self.cudDataSource.saveCreateContext()
            self.showCreateSaleItemForm = false
        }
        
        let form = CreateSaleItemForm(dataSource: cudDataSource, onCreate: createItem, onCancel: cancelItem)
        
        return Modal(NavigationView { form }, onDismiss: cancelItem)
    }
}

#if DEBUG
struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemListView()
    }
}
#endif
