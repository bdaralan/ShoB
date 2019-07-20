//
//  SaleItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 7/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct SaleItemForm: View {
    
    @Binding var model: SaleItemFormModel
    
    var showQuantity: Bool
    
    
    // MARK: - View Body
    
    var body: some View {
        Form {
            SaleItemFormView(model: $model, showQuantity: showQuantity)
        }
    }
}


#if DEBUG
struct SaleItemForm_Previews : PreviewProvider {
    static var previews: some View {
        SaleItemForm(model: .constant(.init()), showQuantity: true)
    }
}
#endif
