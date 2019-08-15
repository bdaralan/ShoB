//
//  StoreListView.swift
//  ShoB
//
//  Created by Dara Beng on 8/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct StoreListView: View {
    
    @EnvironmentObject var storeDataSource: StoreDataSource
    
    @State private var showCreateStoreForm = false
    
    @ObservedObject private var createStoreModel = StoreFormModel()
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(storeDataSource.fetchedResult.fetchedObjects ?? []) { store in
                StoreRow(store: self.storeDataSource.readingObject(store))
            }
        }
        .navigationBarItems(trailing: addNewStoreNavItem)
        .sheet(
            isPresented: $showCreateStoreForm,
            onDismiss: cancelCreateStore,
            content: { self.createStoreForm }
        )
    }
}


// MARK: - Create Store Form

extension StoreListView {
    
    var addNewStoreNavItem: some View {
        Button(action: {
            self.storeDataSource.discardNewObject()
            self.storeDataSource.prepareNewObject()
            self.createStoreModel.store = self.storeDataSource.newObject!
            self.showCreateStoreForm = true
        }) {
            Image(systemName: "plus").imageScale(.large)
        }
    }
    
    var createStoreForm: some View {
        NavigationView {
            StoreForm(
                model: createStoreModel,
                onCreate: commitCreateStore,
                onCancel: cancelCreateStore,
                enableCreate: !createStoreModel.name.isEmpty
            )
                .navigationBarTitle("New Store", displayMode: .inline)
        }
    }
    
    func commitCreateStore() {
        storeDataSource.saveCreateContext()
        storeDataSource.discardNewObject()
        showCreateStoreForm = false
    }
    
    func cancelCreateStore() {
        storeDataSource.discardNewObject()
        storeDataSource.discardCreateContext()
        showCreateStoreForm = false
    }
}


#if DEBUG
struct StoreListView_Previews: PreviewProvider {
    static var previews: some View {
        StoreListView()
    }
}
#endif
