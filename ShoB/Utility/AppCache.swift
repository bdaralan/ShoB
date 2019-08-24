//
//  AppDefaults.swift
//  ShoB
//
//  Created by Dara Beng on 8/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation

/// An object that provide access to application's values stored in `UserDefaults`.
enum AppCache {
    
    typealias UbiquityIdentityToken = (NSCoding & NSCopying & NSObjectProtocol)
    
    
    static var ubiquityIdentityToken: UbiquityIdentityToken? {
        set { UserDefaults.standard.setValue(newValue, forKey: "AppCache.kUbiquityIdentityToken") }
        get { UserDefaults.standard.value(forKey: "AppCache.kUbiquityIdentityToken") as? UbiquityIdentityToken }
    }
}
