//
//  ATCSocialGraphManager.swift
//  ChatApp
//
//  Created by Florian Marcu on 6/5/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

let kSocialGraphDidUpdateNotificationName = NSNotification.Name(rawValue: "kSocialGraphDidUpdateNotificationName")
let kFriendsPresenceUpdateNotificationName = NSNotification.Name(rawValue: "kFriendsPresenceUpdateNotificationName")

protocol ATCSocialGraphManagerProtocol: class {
    var isFriendsUpdateNeeded: Bool {get set}
    func acceptFriendRequest(viewer: ATCUser, from user: ATCUser, completion: @escaping () -> Void)
    func cancelFriendRequest(viewer: ATCUser, to user: ATCUser, completion: @escaping () -> Void)
    func sendFriendRequest(viewer: ATCUser, to user: ATCUser, completion: @escaping () -> Void)
    func fetchFriendships(viewer: ATCUser, completion: @escaping (_ friendships: [ATCChatFriendship]) -> Void)
    func fetchFriends(viewer: ATCUser, completion: @escaping (_ friends: [ATCUser]) -> Void)
    func fetchUsers(viewer: ATCUser, completion: @escaping (_ friends: [ATCUser]) -> Void)
    func removeFriendListeners()
}
