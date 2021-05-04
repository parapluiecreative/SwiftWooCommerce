//
//  ATCFirebaseFriendsSearchDataSource.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/15/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCFirebaseFriendsSearchDataSource: ATCGenericSearchViewControllerDataSource {
    var friends: [ATCUser] = []
    var friendships: [ATCChatFriendship] = []
    var graphManager = ATCFirebaseSocialGraphManager()

    var viewer: ATCUser? {
        didSet {
            update {
            }
        }
    }
    weak var delegate: ATCGenericSearchViewControllerDataSourceDelegate?

    func search(text: String?) {
        guard let viewer = viewer else { return }
        if friends.count == 0 {
            graphManager.fetchUsers(viewer: viewer) {[weak self] (friends) in
                guard let strongSelf = self else { return }
                strongSelf.friends = friends
                var res = friends
                if let text = text, text.count > 0 {
                    res = strongSelf.filter(searchTerm: text)
                }
                strongSelf.delegate?.dataSource(strongSelf, didFetchResults: res)
            }
        } else {
            var res = friends
            if let text = text, text.count > 0 {
                res = self.filter(searchTerm: text)
            }
            delegate?.dataSource(self, didFetchResults: res)
        }
    }

    func update(completion: @escaping () -> Void) {
        guard let viewer = viewer else { return }
        graphManager.fetchFriendships(viewer: viewer) {[weak self] (friendships) in
            guard let `self` = self else { return }
            self.friendships = friendships
            completion()
        }
    }

    fileprivate func filter(searchTerm: String) -> [ATCUser] {
        var res: [ATCUser] = []
        for friend in friends {
            if let str = friend.firstName?.lowercased(), str.contains(searchTerm.lowercased()) {
                res.append(friend)
            } else if let str = friend.lastName?.lowercased(), str.contains(searchTerm.lowercased()) {
                res.append(friend)
            }
        }

        // Return only users who have no relationship with viewer
        return res.filter({ (otherUser) -> Bool in
            !friendships.contains(where: { (friendship) -> Bool in
                return ((friendship.currentUser.uid == viewer?.uid && friendship.otherUser.uid == otherUser.uid) ||
                    (friendship.otherUser.uid == viewer?.uid && friendship.currentUser.uid == otherUser.uid))
            })
        }).sorted { (u1, u2) -> Bool in
            return u1.fullName() < u2.fullName()
        }
    }
}
