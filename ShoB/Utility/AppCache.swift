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
    
    
    @UserDefaultsOptionalValue(forKey: "AppCache.kUbiquityIdentityToken", default: nil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
}
