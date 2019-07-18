//
//  SaleItemRow.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct SaleItemRow: View {
    
    /// The source item.
    @ObjectBinding var sourceItem: SaleItem
    
    /// The data source that will update and save the item.
    @ObjectBinding var dataSource: CUDDataSource<SaleItem>
    
    /// Triggered when the item is updated.
    var onUpdated: (() -> Void)?
    
    /// The item to be updated.
    ///
    /// This is the source item, but get from data source's update context.
    var saleItemToUpdate: SaleItem {
        sourceItem.get(from: dataSource.updateContext)
    }
    
    
    var body: some View {
        let saleItemDetailView = SaleItemDetailView(saleItem: saleItemToUpdate, onUpdated: {
            self.dataSource.sourceContext.quickSave()
            self.onUpdated?()
        })
        
        return NavigationLink(destination: saleItemDetailView) { // row content
            HStack {
                Text(self.sourceItem.name)
                Spacer()
                Text(verbatim: "\(Currency(self.sourceItem.price))")
            }
        }
    }
}

#if DEBUG
struct SaleItemRow_Previews : PreviewProvider {
    static let cud = CUDDataSource<SaleItem>(context: CoreDataStack.current.mainContext)
    static let item = SaleItem(context: cud.sourceContext)
    static var previews: some View {
        SaleItemRow(sourceItem: item, dataSource: cud, onUpdated: {})
    }
}
#endif
