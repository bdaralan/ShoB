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
    
    @State private var showCreateStoreFailedAlert = false
    
    @ObservedObject private var createStoreModel = StoreFormModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(storeDataSource.fetchedResult.fetchedObjects ?? [], id: \.self) { store in
                StoreRow(
                    store: self.storeDataSource.readObject(store),
                    onSetCurrent: self.viewReloader.forceReload,
                    onDeleted: self.viewReloader.forceReload
                )
            }
        }
        .navigationBarItems(trailing: addNewStoreNavItem)
        .sheet(isPresented: $showCreateStoreForm, onDismiss: cancelCreateStore, content: { self.createStoreForm })
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
        .onLongPressGesture { // MARK: Test Code :]
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
                .alert(isPresented: $showCreateStoreFailedAlert, content: { createStoreFailedAlert })
        }
    }
    
    var createStoreFailedAlert: Alert {
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
                self.showCreateStoreFailedAlert = !self.createStoreModel.store!.isValid()
            }
            
            // assign user record id to store object
            guard let recordID = recordID else { return }
            self.createStoreModel.store!.setOwnerID(with: recordID)
            
            // save store object and dismiss form
            guard self.createStoreModel.store!.isValid() else { return }
            self.storeDataSource.saveCreateContext()
            
            // set as current store if there is no current store
            if AppCache.currentStoreUniqueID == nil {
                Store.setCurrent(self.createStoreModel.store)
            }
            
            self.storeDataSource.discardNewObject()
            self.showCreateStoreForm = false
        }
    }
    
    func cancelCreateStore() {
        storeDataSource.discardNewObject()
        storeDataSource.discardCreateContext()
        showCreateStoreForm = false
    }
}


struct StoreListView_Previews: PreviewProvider {
    static var previews: some View {
        StoreListView()
    }
}
