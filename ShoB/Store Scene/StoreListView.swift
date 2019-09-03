//
//  StoreListView.swift
//  ShoB
//
//  Created by Dara Beng on 8/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CloudKit


struct StoreListView: View {
    
    @EnvironmentObject var storeDataSource: StoreDataSource
    
    @State private var showCreateStoreForm = false
    
    @State private var showCannotCreateStoreAlert = false
    
    @State private var currentStore = Store.current()
    
    @ObservedObject private var createStoreModel = StoreFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    @ObservedObject private var storeChangedObserver = NotificationObserver(name: .init(Store.kCurrentStoreDidChange))
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(storeDataSource.fetchedResult.fetchedObjects ?? []) { store in
                StoreRow(
                    store: self.storeDataSource.readObject(store),
                    showCheckMark: self.isCurrentStore(store),
                    onDeleted: { self.viewReloader.forceReload() }
                )
                    .contextMenu(self.storeRowContextMenu(for: store))
            }
        }
        .navigationBarItems(trailing: addNewStoreNavItem)
        .sheet(
            isPresented: $showCreateStoreForm,
            onDismiss: cancelCreateStore,
            content: { self.createStoreForm }
        )
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Create Store Form

extension StoreListView {
    
    var addNewStoreNavItem: some View {
        Button(action: {
            // discard and prepare a new object for the form
            let dataSource = self.storeDataSource
            dataSource.discardNewObject()
            dataSource.prepareNewObject()
            self.createStoreModel.store = dataSource.newObject!
            self.showCreateStoreForm = true
        }) {
            Image(systemName: "plus").imageScale(.large)
        }
        .onLongPressGesture { // MARK: Test Code
            Importer.importSampleData()
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
                .alert(isPresented: $showCannotCreateStoreAlert, content: { cannotCreateStoreAlert })
        }
    }
    
    var cannotCreateStoreAlert: Alert {
        Alert(
            title: Text("Create Failed"),
            message: Text("""
            Unable to get user's ID.
            Please try again and make sure you are connected to the Internet.
            """),
            dismissButton: Alert.Button.default(Text("Dismiss"))
        )
    }
    
    func commitCreateStore() {
        // MARK: TODO add activity indicator while fetching user record
        CKContainer.default().fetchUserRecordID { recordID, error in
            defer {
                // show error alert if cannot get user record id or the store is invalid
                self.showCannotCreateStoreAlert = !self.createStoreModel.store!.isValid()
            }
            
            // assign user record id to store object
            guard let recordID = recordID else { return }
            self.createStoreModel.store!.setOwnerID(with: recordID)
            
            // save store object and dismiss form
            guard self.createStoreModel.store!.isValid() else { return }
            self.storeDataSource.saveCreateContext()
            self.storeDataSource.discardNewObject()
            self.showCreateStoreForm = false
        }
    }
    
    func cancelCreateStore() {
        storeDataSource.discardNewObject()
        storeDataSource.discardCreateContext()
        showCreateStoreForm = false
    }
    
    func storeRowContextMenu(for store: Store) -> ContextMenu<AnyView> {
        ContextMenu {
            Button(action: {
                let shouldBecomeCurrent = !self.isCurrentStore(store)
                self.setCurrentStore(store, current: shouldBecomeCurrent)
            }) {
                Text(isCurrentStore(store) ? "Deselect Current Store" : "Set Current Store")
                Image(systemName: isCurrentStore(store) ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .imageScale(.small)
            }
            .eraseToAnyView()
        }
    }
    
    /// Set or unset the store as current store.
    ///
    /// If the store is not the current store, pass `false` will do nothing.
    /// - Parameter store: The store to be set.
    /// - Parameter current: Pass `true` to set as current; otherwise, `false`.
    func setCurrentStore(_ store: Store, current: Bool) {
        switch current {
        case true:
            Store.setCurrent(store)
        case false:
            guard isCurrentStore(store) else { return }
            Store.setCurrent(nil)
        }
    }
    
    /// Check is the store is the current store.
    /// - Parameter store: The store to be checked.
    func isCurrentStore(_ store: Store) -> Bool {
        store.objectID == currentStore?.objectID
    }
    
    func setupOnAppear() {
        storeChangedObserver.onReceived = { notification in
            let store = notification.object as? Store
            self.currentStore = store
        }
    }
}


struct StoreListView_Previews: PreviewProvider {
    static var previews: some View {
        StoreListView()
    }
}
