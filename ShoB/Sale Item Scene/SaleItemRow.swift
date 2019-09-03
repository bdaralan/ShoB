//
//  SaleItemRow.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays sale item in a list row.
struct SaleItemRow: View {
    
    @EnvironmentObject var saleItemDataSource: SaleItemDataSource
    
    /// The source item to view or update.
    @ObservedObject var saleItem: SaleItem
    
    var onDeleted: (() -> Void)?
        
    @State private var saleItemModel = SaleItemFormModel()
    
    @ObservedObject private var navigationState = NavigationStateHandler()
    
    @State private var showDeleteAlert = false
    
    
    // MARK: - Body
    
    var body: some View {
        NavigationLink(destination: saleItemDetailView, isActive: $navigationState.isPushed) { // row content
            HStack {
                Text(saleItem.name)
                Spacer()
                Text(verbatim: "\(Currency(saleItem.price))")
            }
        }
    }
}


// MARK: - Body Component

extension SaleItemRow {
    
    var saleItemDetailView: some View {
        SaleItemForm(
            model: $saleItemModel,
            onUpdate: updateSaleItem,
            enableUpdate: saleItem.hasPersistentChangedValues && saleItem.isValid(),
            rowActions: [
                .init(title: "Delete", isDestructive: true, action: { self.showDeleteAlert = true })
            ]
        )
            .onAppear(perform: setupOnAppear)
            .navigationBarTitle("Item Details", displayMode: .inline)
            .modifier(DeleteAlertModifer($showDeleteAlert, title: "Delete Item", action: deleteSaleItem))
    }
    
    func setupOnAppear() {
        // DEVELOPER NOTE:
        // Do the assignment here for now until finding a better place for the assignment
        saleItemModel = .init(saleItem: saleItem)
        saleItemDataSource.setUpdateObject(saleItem)
        
        navigationState.onPopped = { // discard unsaved changes
            self.saleItemDataSource.setUpdateObject(nil)
            guard self.saleItem.hasChanges, let context = self.saleItem.managedObjectContext else { return }
            context.rollback()
        }
    }
    
    /// Save sale item's changes.
    func updateSaleItem() {
        let result = saleItemDataSource.saveUpdateObject()
        switch result {
        case .saved, .unchanged: break
        case .failed:
            print("failed to update order \(saleItemDataSource.updateObject?.description ?? "nil")")
        }
    }
    
    func deleteSaleItem() {
        saleItemDataSource.delete(saleItem, saveContext: true)
        navigationState.pop()
        onDeleted?()
    }
}


struct SaleItemRow_Previews : PreviewProvider {
    static let saleItem = SaleItem(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        SaleItemRow(saleItem: saleItem, onDeleted: {})
    }
}
