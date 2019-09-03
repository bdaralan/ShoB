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
                    onDeleted: { self.viewReloader.forceReload() }
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
            // discard and prepare a new item for the form
            let dataSource = self.saleItemDataSource
            dataSource.discardNewObject()
            dataSource.prepareNewObject()
            dataSource.newObject!.store = Store.current()?.get(from: dataSource.createContext)
            self.newSaleItemModel = .init(saleItem: dataSource.newObject!)
            self.showCreateSaleItemForm = true
        }, label: {
            Image(systemName: "plus").imageScale(.large)
        })
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
    
    func saveNewSaleItem() {
        let result = saleItemDataSource.saveNewObject()
        switch result {
        case .saved: break
        case .failed: break
        case .unchanged: break
        }
        print(result)
        showCreateSaleItemForm = false
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
