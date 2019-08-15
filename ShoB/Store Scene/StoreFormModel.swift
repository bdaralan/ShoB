//
//  StoreFormModel.swift
//  ShoB
//
//  Created by Dara Beng on 8/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


class StoreFormModel: ObservableObject {
    weak var store: Store? {
        didSet {
            name = store?.name ?? ""
            phone = store?.phone ?? ""
            email = store?.email ?? ""
            address = store?.address ?? ""
        }
    }
    
    @Published var name = "" {
        didSet { store?.name = name }
    }
    
    @Published var phone = "" {
        didSet { store?.phone = phone }
    }
    
    @Published var email = "" {
        didSet { store?.email = email.lowercased() }
    }
    
    @Published var address = "" {
        didSet { store?.address = address }
    }
}
