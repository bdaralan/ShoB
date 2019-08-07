//
//  SaleItemDetailView.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays sale item's details.
struct SaleItemDetailView: View, EditableForm {
    
    @ObservedObject var saleItem: SaleItem
    
    /// The model to view or edit sale item.
    @Binding var model: SaleItemFormModel
    
    var onSave: () -> Void
    
    var onDelete: () -> Void
    
    var isSaveEnabled: Bool {
        saleItem.hasPersistentChangedValues && saleItem.hasValidInputs()
    }
    
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                SaleItemFormBody(model: $model, mode: .saleItem)
            }
            Section {
                Button("Delete", action: onDelete)
                    .buttonStyle(CenterButtonStyle(.destructive))
            }
        }
        .navigationBarTitle("Item Details", displayMode: .inline)
        .navigationBarItems(trailing: saveNavItem(title: "Update"))
    }
}


#if DEBUG
struct SaleItemDetailView_Previews : PreviewProvider {
    static let saleItem = SaleItem(context: CoreDataStack.current.mainContext)
    static var previews: some View {
        SaleItemDetailView(saleItem: saleItem, model: .constant(.init(saleItem: saleItem)), onSave: {}, onDelete: {})
    }
}
#endif
