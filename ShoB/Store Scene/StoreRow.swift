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
    
    /// An antion to perform when the store is deleted.
    var onDeleted: (() -> Void)?
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: storeDetailView, isActive: $navigationState.isPushed) {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.name).fontWeight(.semibold)
                Group {
                    Text.contactInfo(image: Image.SFCustomer.phone, text: store.phone)
                    Text.contactInfo(image: Image.SFCustomer.email, text: store.email)
                    Text.contactInfo(image: Image.SFCustomer.address, text: store.address)
                }
                .font(.caption)
            }
        }
    }
}


// MARK: - Body Component

extension StoreRow {
    
    var storeDetailView: some View {
        StoreForm(
            model: storeModel,
            onUpdate: updateStore,
            enableUpdate: store.hasPersistentChangedValues && store.hasValidInputs(),
            rowActions: rowActions()
        )
            .navigationBarTitle("Store Details", displayMode: .inline)
            .onAppear(perform: setupOnAppear)
    }
    
    func setupOnAppear() {
        storeModel.store = store
        navigationState.onPopped = {
            self.storeDataSource.saveUpdateContext()
        }
    }
    
    func rowActions() -> [MultiPurposeFormRowAction] {
        let actions: [MultiPurposeFormRowAction] = [
            .init(title: "Delete", isDestructive: true, action: deleteStore)
        ]
        return actions
    }
    
    func updateStore() {
        store.objectWillChange.send()
        storeDataSource.saveUpdateContext()
    }
    
    func deleteStore() {
        storeDataSource.delete(store, saveContext: true)
        onDeleted?()
        navigationState.pop()
    }
}


#if DEBUG
struct StoreRow_Previews: PreviewProvider {
    static var previews: some View {
        StoreRow(store: .init(context: CoreDataStack.current.mainContext))
    }
}
#endif
