//
//  SaleItemList.swift
//  ShoB
//
//  Created by Dara Beng on 6/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct SaleItemList : View {
    
    @State var items = sampleItems()
    
    /// Action to perform when an item is selected.
    ///
    /// Set this block to do custom action.
    /// Otherwise, The view will show the item details.
    var onItemSelected: ((SaleItem, SaleItemList) -> Void)?
    
    
    var body: some View {
        List(items) { item in
            if self.onItemSelected == nil { // default behavior, show item details
                NavigationButton(destination: Text(item.name),
                                 label: { Text(item.name) }
                )
            
            } else { // custom behavior
                Button(action: { self.onItemSelected?(item, self)},
                       label: { Text(item.name) }
                )
            }
        }
    }
}

#if DEBUG
struct SaleItemList_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemList()
    }
}
#endif


func sampleItems() -> [SaleItem] {
    let context = CoreDataStack.current.mainContext
    var items = [SaleItem]()
    for i in 1...20 {
        let item = (SaleItem(context: context))
        item.name = "Item #\(i)"
        item.price = Cent(i * 10)
        items.append(item)
    }
    return items
}
