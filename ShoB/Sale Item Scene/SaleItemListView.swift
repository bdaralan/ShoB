//
//  SaleItemListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct SaleItemListView: View {
    
    @EnvironmentObject var dataSource: FetchedDataSource<SaleItem>
    
    @State var showCreateSaleItemForm = false
    
    /// Triggered when an item is selected.
    ///
    /// Set this block to perform custom action.
    /// Otherwise, the default behavior is to show the item's details.
    var onItemSelected: ((SaleItem, SaleItemListView) -> Void)?
    
    
    var body: some View {
        List(dataSource.fetchController.fetchedObjects ?? []) { saleItem in
            if self.onItemSelected == nil { // default behavior
                SaleItemRow(sourceItem: saleItem, dataSource: self.dataSource.cud, onUpdated: nil)
            } else { // custom behavior
                Button(saleItem.name, action: { self.onItemSelected?(saleItem, self) })
            }
        }
        .navigationBarItems(trailing: addNewSaleItemNavItem)
        .sheet(
            isPresented: $showCreateSaleItemForm,
            onDismiss: dismisCreateSaleItem,
            content: { self.createSaleItemForm }
        )
    }
    

    var addNewSaleItemNavItem: some View {
        Button(action: {
            self.dataSource.cud.discardNewObject()
            self.dataSource.cud.prepareNewObject()
            self.dataSource.cud.willChange.send()
            self.showCreateSaleItemForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
        .accentColor(.accentColor)
    }
    
    var createSaleItemForm: some View {
        NavigationView {
            CreateSaleItemForm(
                cudDataSource: dataSource.cud,
                onCreated: dismisCreateSaleItem,
                onCancelled: dismisCreateSaleItem
            )
        }
    }
    
    
    func dismisCreateSaleItem() {
        self.dataSource.cud.discardCreateContext()
        self.showCreateSaleItemForm = false
    }
}

#if DEBUG
struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemListView()
    }
}
#endif
