//
//  SaleItemListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays store's sale items in a list.
struct SaleItemListView: View {
    
    @EnvironmentObject var dataSource: FetchedDataSource<SaleItem>
    
    @State private var showCreateSaleItemForm = false
    
    @State private var newSaleItemModel = SaleItemFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(dataSource.fetchController.fetchedObjects ?? []) {  saleItem in
                SaleItemRow(
                    saleItem: saleItem.get(from: self.dataSource.cud.updateContext),
                    onSave: self.saveSaleItemRowChanges,
                    onDelete: self.deleteSaleItem
                )
            }
        }
        .navigationBarItems(trailing: addNewSaleItemNavItem)
        .sheet(
            isPresented: $showCreateSaleItemForm,
            onDismiss: dismisCreateSaleItem,
            content: { self.createSaleItemForm }
        )
    }
}
 

// MARK: - Body Component

extension SaleItemListView {
    
    var addNewSaleItemNavItem: some View {
        Button(action: {
            // discard and create new item for the form
            self.dataSource.cud.discardNewObject()
            self.dataSource.cud.prepareNewObject()
            self.newSaleItemModel = .init(saleItem: self.dataSource.cud.newObject!)
            self.showCreateSaleItemForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
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
}


// MARK: - Method

extension SaleItemListView {
    
    func dismisCreateSaleItem() {
        dataSource.cud.discardCreateContext()
        showCreateSaleItemForm = false
    }
    
    func saveNewSaleItem() {
        dataSource.cud.saveCreateContext()
        showCreateSaleItemForm = false
    }
    
    func saveSaleItemRowChanges(item: SaleItem) {
        if item.hasPersistentChangedValues {
            dataSource.cud.saveUpdateContext()
        } else {
            dataSource.cud.discardUpdateContext()
        }
        item.objectWillChange.send()
    }
    
    func deleteSaleItem(_ item: SaleItem) {
        dataSource.cud.delete(item, saveContext: true)
        viewReloader.forceReload()
    }
}


#if DEBUG
struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemListView()
    }
}
#endif
