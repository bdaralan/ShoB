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
        
    @State private var showCreateItemFailedAlert = false
    
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            SearchTextField(searchField: searchField)
            ForEach(saleItemDataSource.fetchedResult.fetchedObjects ?? [], id: \.self) {  saleItem in
                SaleItemRow(
                    saleItem: self.saleItemDataSource.readObject(saleItem),
                    onDeleted: self.viewReloader.forceReload
                )
            }
        }
        .onAppear(perform: setupView)
        .navigationBarItems(trailing: addNewSaleItemNavItem)
        .sheet(isPresented: $showCreateSaleItemForm, onDismiss: dismisCreateSaleItem, content: { self.createSaleItemForm })
        .alert(isPresented: $showCreateItemFailedAlert, content: { .creatObjectWithoutCurrentStore(object: "Item") })
    }
}
 

// MARK: - Body Component

extension SaleItemListView {
    
    var addNewSaleItemNavItem: some View {
        Button(action: beginCreateNewSaleItem) {
            Image(systemName: "plus").imageScale(.large)
        }
    }
    
    var createSaleItemForm: some View {
        NavigationView {
            SaleItemForm(
                model: $newSaleItemModel,
                onCreate: saveNewSaleItem,
                onCancel: dismisCreateSaleItem,
                enableCreate: newSaleItemModel.saleItem!.isValid()
            )
                .navigationBarTitle("New Item", displayMode: .inline)
        }
    }
}


// MARK: - Method

extension SaleItemListView {
    
    func dismisCreateSaleItem() {
        saleItemDataSource.discardCreateContext()
        showCreateSaleItemForm = false
    }
    
    func beginCreateNewSaleItem() {
        if let store = Store.current(from: saleItemDataSource.createContext) {
            // discard and prepare a new item for the form
            saleItemDataSource.discardNewObject()
            saleItemDataSource.prepareNewObject()
            saleItemDataSource.newObject!.store = store
            newSaleItemModel = .init(saleItem: saleItemDataSource.newObject!)
            showCreateSaleItemForm = true
        } else {
            showCreateItemFailedAlert = true
        }
    }
    
    func saveNewSaleItem() {
        let result = saleItemDataSource.saveNewObject()
        switch result {
        case .saved: showCreateSaleItemForm = false
        case .failed: break // TODO: add alert
        case .unchanged: break
        }
    }
    
    func setupView() {
        fetchSaleItems()
        setupSearchField()
    }
    
    func fetchSaleItems() {
        if let storeID = AppCache.currentStoreUniqueID {
            saleItemDataSource.performFetch(SaleItem.requestObjects(storeID: storeID))
        } else {
            saleItemDataSource.performFetch(SaleItem.requestNoObject())
        }
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


struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemListView()
    }
}
