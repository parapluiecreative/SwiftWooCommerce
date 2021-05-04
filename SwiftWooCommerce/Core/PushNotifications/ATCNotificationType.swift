//
//  ATCNotificationType.swift
//  ChatApp
//
//  Created by Duy Bui on 6/27/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Foundation

enum ATCNotificationType: String {
    case chatAppNewMessage = "chatAppNewMessage"
    case datingAppNewMatch = "datingAppNewMatch"
    
    var notiticationName: Notification.Name {
        switch self {
        case .chatAppNewMessage:
            return .didReceiveChatAppNewMessage
        case .datingAppNewMatch:
            return .didReceiveDatingAppNewMatch
        }
    }
}

extension Notification.Name {
    static let didReceiveChatAppNewMessage = Notification.Name("didReceiveChatAppNewMessage")
    static let didReceiveDatingAppNewMatch = Notification.Name("didReceiveDatingAppNewMatch")
}
