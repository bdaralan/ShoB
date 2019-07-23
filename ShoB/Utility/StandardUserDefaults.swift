//
//  StandardUserDefaults.swift
//  ShoB
//
//  Created by Dara Beng on 6/16/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


enum StandardUserDefaults {
    
    static let unknownUserIdentityToken = "unknownUserIdentityToken"
    
    @UserDefaultsValue(forKey: "kSetting.lastUserIdentityToken", default: unknownUserIdentityToken)
    static var lastUserIdentityToken: String
    
    @UserDefaultsValue(forKey: "kSetting.userIdentityTokenDictionary", default: [String: UbiquityIdentityToken]())
    static var userIdentityTokenDictionary: [String: UbiquityIdentityToken]
}


@propertyWrapper
struct UserDefaultsValue<T> {
    
    let key: String
    
    let defaultValue: T
    
    var wrappedValue: T {
        set { UserDefaults.standard.set(newValue, forKey: key) }
        get { UserDefaults.standard.value(forKey: key) as? T ?? defaultValue }
    }
    
    
    init(forKey key: String, default value: T) {
        self.key = key
        self.defaultValue = value
    }
}
