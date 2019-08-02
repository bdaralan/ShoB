//
//  SaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view used to view or edit sale item.
struct SaleItemForm: View {
    
    @Binding var model: SaleItemFormModel
    
    var mode: SaleItemFormBody.Mode
    
    
    // MARK: - Body
    
    var body: some View {
        Form {
            SaleItemFormBody(model: $model, mode: mode)
        }
    }
}


#if DEBUG
struct SaleItemForm_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemForm(model: .constant(.init()), mode: .saleItem)
    }
}
#endif
