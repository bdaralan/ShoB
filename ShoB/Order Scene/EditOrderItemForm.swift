//
//  EditOrderItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 8/1/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct EditOrderItemForm: View {
    
    @Binding var orderItemModel: SaleItemFormModel
    
    var onDelete: () -> Void
    
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                SaleItemFormBody(model: $orderItemModel, mode: .orderItem)
            }
            Section {
                Button("Remove", action: onDelete)
                    .buttonStyle(RowCenterButtonStyle(.destructive))
            }
        }
    }
}


#if DEBUG
struct EditOrderItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditOrderItemForm(orderItemModel: .constant(.init()), onDelete: {})
    }
}
#endif
