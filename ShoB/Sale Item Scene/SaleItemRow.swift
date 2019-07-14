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
    
    var onUpdate: () -> Void
    
    var body: some View {
        let saleItemDetailView = SaleItemDetailView(saleItem: saleItem, onUpdate: onUpdate)
        
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
        SaleItemRow(saleItem: SaleItem(context: CoreDataStack.current.mainContext), onUpdate: {})
    }
}
#endif
