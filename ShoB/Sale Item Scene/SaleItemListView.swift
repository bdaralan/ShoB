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
    
    @State private var showCreateSaleItemForm = false
    
    @State private var newSaleItemModel = SaleItemForm.Model()
    
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
            // discard and create new item for the form
            self.dataSource.cud.discardNewObject()
            self.dataSource.cud.prepareNewObject()
            self.newSaleItemModel = .init(item: self.dataSource.cud.newObject!)
            self.showCreateSaleItemForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
        .accentColor(.accentColor)
    }
    
    var createSaleItemForm: some View {
        NavigationView {
            CreateSaleItemForm(
                model: $newSaleItemModel,
                onCreate: saveNewSaleItem,
                onCancel: dismisCreateSaleItem
            )
        }
    }
    
    
    func dismisCreateSaleItem() {
        dataSource.cud.discardCreateContext()
        showCreateSaleItemForm = false
    }
    
    func saveNewSaleItem() {
        newSaleItemModel.assign()
        dataSource.cud.saveCreateContext()
        showCreateSaleItemForm = false
    }
}


#if DEBUG
struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemListView()
    }
}
#endif
