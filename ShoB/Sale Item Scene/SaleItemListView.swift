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
    
    @State private var newSaleItemModel = SaleItemForm.Model()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(dataSource.fetchController.fetchedObjects ?? []) { saleItem in
                SaleItemRow(
                    saleItem: saleItem.get(from: self.dataSource.cud.updateContext),
                    onSave: { self.saveSaleItemRowChanges($0) },
                    onDelete: { self.dataSource.cud.delete($0, saveContext: true) }
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
    

    // MARK: - Body Component
    
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
    
    
    // MARK: - Method
    
    func dismisCreateSaleItem() {
        dataSource.cud.discardCreateContext()
        showCreateSaleItemForm = false
    }
    
    func saveNewSaleItem() {
        dataSource.cud.saveCreateContext()
        showCreateSaleItemForm = false
    }
    
    func saveSaleItemRowChanges(_ item: SaleItem) {
        item.objectWillChange.send() // send change to refresh UI
        
        if item.hasPersistentChangedValues {
            dataSource.cud.saveUpdateContext()
        } else {
            dataSource.cud.discardUpdateContext()
        }
    }
}


#if DEBUG
struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemListView()
    }
}
#endif
