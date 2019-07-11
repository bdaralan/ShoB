//
//  SaleItemRow.swift
//  ShoB
//
//  Created by Dara Beng on 7/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct SaleItemRow: View {
    
    @ObjectBinding var saleItem: SaleItem
    
    var onUpdated: (SaleItem) -> Void
    
    var body: some View {
        
        let saleItemDetailView = SaleItemDetailView(saleItem: saleItem, onUpdated: {
            self.onUpdated(self.saleItem)
        })
        
        return NavigationLink(destination: saleItemDetailView) { // row content
            HStack {
                Text(self.saleItem.name)
                Spacer()
                Text(verbatim: "\(Currency(self.saleItem.price))")
            }
        }
    }
}

#if DEBUG
struct SaleItemRow_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemRow(saleItem: SaleItem(context: CoreDataStack.current.mainContext), onUpdated: { _ in })
    }
}
#endif
