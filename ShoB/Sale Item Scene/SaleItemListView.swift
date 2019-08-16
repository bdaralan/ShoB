//
//  SaleItemListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine


/// A view that displays store's sale items in a list.
struct SaleItemListView: View {
    
    @EnvironmentObject var saleItemDataSource: SaleItemDataSource
    
    @State private var showCreateSaleItemForm = false
    
    @State private var newSaleItemModel = SaleItemFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    @ObservedObject private var searchField = SearchField()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            SearchTextField(searchField: searchField)
            ForEach(saleItemDataSource.fetchedResult.fetchedObjects ?? []) {  saleItem in
                SaleItemRow(
                    saleItem: self.saleItemDataSource.readObject(saleItem),
                    onSave: self.saveSaleItemRowChanges,
                    onDelete: self.deleteSaleItem
                )
            }
        }
        .onAppear(perform: setupSearchField)
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
            self.saleItemDataSource.discardNewObject()
            self.saleItemDataSource.prepareNewObject()
            self.newSaleItemModel = .init(saleItem: self.saleItemDataSource.newObject!)
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
        saleItemDataSource.discardCreateContext()
        showCreateSaleItemForm = false
    }
    
    func saveNewSaleItem() {
        saleItemDataSource.saveNewObject()
        showCreateSaleItemForm = false
    }
    
    func saveSaleItemRowChanges(item: SaleItem) {
        saleItemDataSource.saveUpdateObject()
    }
    
    func deleteSaleItem(_ item: SaleItem) {
        saleItemDataSource.delete(item, saveContext: true)
        viewReloader.forceReload()
    }
    
    func setupSearchField() {
        searchField.placeholder = "Search by name or price"
        searchField.onSearchTextDebounced = { searchText in
            let search = searchText.isEmpty ? nil : searchText
            self.saleItemDataSource.performFetch(SaleItem.requestAllObjects(filterNameOrPrice: search))
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
