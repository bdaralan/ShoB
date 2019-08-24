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
    
    private static let ubiquityIdentityTokenNil: UbiquityIdentityToken? = nil
    
    
    @UserDefaultsValue(forKey: "CoreDataStack.kCachedCurrentUserIdentity", default: ubiquityIdentityTokenNil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
}
