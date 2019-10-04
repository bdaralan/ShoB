//
//  StoreRow.swift
//  ShoB
//
//  Created by Dara Beng on 8/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct StoreRow: View {
    
    @EnvironmentObject var storeDataSource: StoreDataSource
    
    /// The store object in the `DataSource`'s `updateContext`.
    @ObservedObject var store: Store
    
    @ObservedObject private var storeModel = StoreFormModel()
    
    @ObservedObject private var navigationState = NavigationStateHandler()
    
    /// An action to perform when a store is set as as current.
    var onSetCurrent: (() -> Void)?
    
    /// An antion to perform when the store is deleted.
    var onDeleted: (() -> Void)?
    
    @State private var showDeleteAlert = false
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: storeDetailView, isActive: $navigationState.isPushed) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name).fontWeight(.semibold)
                    Group {
                        Text.contactInfo(image: Image.SFCustomer.phone, text: store.phone)
                        Text.contactInfo(image: Image.SFCustomer.email, text: store.email)
                        Text.contactInfo(image: Image.SFCustomer.address, text: store.address)
                    }
                    .font(.caption)
                }
                .layoutPriority(1)
                
                Spacer()
                Image(systemName: "checkmark.circle")
                    .imageScale(.large)
                    .padding(.horizontal)
                    .opacity(store.isCurrent ? 1 : 0)
            }
            .contextMenu(menuItems: contextMenuItems)
            .modifier(DeleteAlertModifer($showDeleteAlert, title: "Delete Store", action: deleteStore))
        }
    }
}


// MARK: - Body Component

extension StoreRow {
    
    var storeDetailView: some View {
        StoreForm(
            model: storeModel,
            onUpdate: updateStore,
            enableUpdate: store.hasPersistentChangedValues && store.isValid(),
            rowActions: []
        )
            .onAppear(perform: setupStoreDetailView)
            .navigationBarTitle("Store Details", displayMode: .inline)
    }
    
    func contextMenuItems() -> some View {
        Group {
            Button(action: setCurrentStore) {
                Text(store.isCurrent ? "Unset Current" : "Set Current")
                Image(systemName: store.isCurrent ? "xmark.circle" : "checkmark.circle")
            }
            Button(action: confirmDeleteStore) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
    
    func setupStoreDetailView() {
        storeModel.store = store
        storeDataSource.setUpdateObject(store)
        navigationState.onPopped = {
            self.storeDataSource.setUpdateObject(nil)
            self.storeDataSource.discardUpdateContext()
        }
    }
    
    /// Save store's changes.
    func updateStore() {
        let result = storeDataSource.saveUpdateObject()
        switch result {
        case .saved, .unchanged: break
        case .failed:
            print("failed to update order \(storeDataSource.updateObject?.description ?? "nil")")
        }
    }
    
    func confirmDeleteStore() {
        showDeleteAlert = true
    }
    
    func deleteStore() {
        if AppCache.currentStoreUniqueID == store.uniqueID {
            Store.setCurrent(nil)
        }
        storeDataSource.delete(store, saveContext: true)
        onDeleted?()
    }
    
    func setCurrentStore() {
        Store.setCurrent(store.isCurrent ? nil : store)
        onSetCurrent?()
    }
}


struct StoreRow_Previews: PreviewProvider {
    static var previews: some View {
        StoreRow(store: .init(context: CoreDataStack.current.mainContext))
    }
}
