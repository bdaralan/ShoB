//
//  NotificationObserver.swift
//  ShoB
//
//  Created by Dara Beng on 8/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


/// An object that can perform action when a notification is received.
class NotificationObserver: ObservableObject {
    
    /// An action to perform when the notification is received.
    var onReceived: ((Notification) -> Void)?
    
    
    init(name: Notification.Name) {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedNotification), name: name, object: nil)
    }
    
    
    @objc private func receivedNotification(_ notification: Notification) {
        onReceived?(notification)
    }
}
