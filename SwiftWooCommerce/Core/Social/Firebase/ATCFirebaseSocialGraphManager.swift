//
//  ATCFirebaseSocialGraphManager.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/15/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore

class ATCFirebaseSocialGraphManager: ATCSocialGraphManagerProtocol {
    var isFriendsUpdateNeeded: Bool = false
    
    let reportingManager = ATCFirebaseUserReporter()
    
    var allFriendListeners: [ListenerRegistration] = []

    func fetchFriends(viewer: ATCUser, completion: @escaping (_ friends: [ATCUser]) -> Void) {
        self.fetchFriendships(viewer: viewer) { (friendships) in
            completion(friendships.compactMap({$0.type == .mutual ? $0.otherUser : nil}))
        }
    }
    
    func removeFriendListeners() {
        for friendListener in allFriendListeners {
            friendListener.remove()
        }
        self.allFriendListeners.removeAll()
    }
    
    func fetchFriendships(viewer: ATCUser, completion: @escaping (_ friendships: [ATCChatFriendship]) -> Void) {
        if self.isFriendsUpdateNeeded {
            self.removeFriendListeners() // close previous listener
        }
        
        guard let uid = viewer.uid else { return }
        let serialQueue = DispatchQueue(label: "com.iosapptemplates.friendshipsfetching.queue")
        
        // Exclude all users that are reported
        reportingManager.userIDsBlockedOrReported(by: viewer) { (illegalUserIDsSet) in
            let ref = Firestore.firestore().collection("friendships").whereField("user1", isEqualTo: uid)
            let usersRef = Firestore.firestore().collection("users")
            ref.getDocuments { (querySnapshot, error) in
                if error != nil {
                    completion([])
                    return
                }
                guard let querySnapshot = querySnapshot else {
                    return
                }
                let documentsAsUser1 = querySnapshot.documents
                let ref2 = Firestore.firestore().collection("friendships").whereField("user2", isEqualTo: uid)
                ref2.getDocuments { (querySnapshot, error) in
                    if error != nil {
                        completion([])
                        return
                    }
                    guard let querySnapshot = querySnapshot else {
                        completion([])
                        return
                    }
                    var hydratedUsers: [ATCUser] = []
                    let documentsAsUser2 = querySnapshot.documents
                    let otherUserIDsAsUser1 = documentsAsUser1.compactMap({$0.data()["user2"] as? String}).filter({!illegalUserIDsSet.contains($0)})
                    let otherUserIDsAsUser2 = documentsAsUser2.compactMap({$0.data()["user1"] as? String}).filter({!illegalUserIDsSet.contains($0)})
                    let friendsIDs = otherUserIDsAsUser1.filter({otherUserIDsAsUser2.contains($0)}) // Mutual friends
                    let outboundRequestsUserIDs = Set(otherUserIDsAsUser1.filter({!otherUserIDsAsUser2.contains($0)})) // I made the request, but it wasn't accepted yet
                    let inboundRequestsUserIDs = Set(otherUserIDsAsUser2.filter({!otherUserIDsAsUser1.contains($0)})) // They made a request, but I didn't accept it yet
                    
                    let allUniqueUsersIDsToBeHydrated = Array(Set(otherUserIDsAsUser1 + otherUserIDsAsUser2))
                    if allUniqueUsersIDsToBeHydrated.count == 0 {
                        completion([])
                        return
                    }
                    for (index, userID) in allUniqueUsersIDsToBeHydrated.enumerated() {
                        if self.isFriendsUpdateNeeded {
                            let friendListener = usersRef.document(userID).addSnapshotListener { (document, error) in
                                if let userDict = document?.data() {
                                    let user = ATCUser(representation: userDict)
                                    serialQueue.sync {
                                        if hydratedUsers.indices.contains(index) {
                                            hydratedUsers.remove(at: index)
                                            hydratedUsers.insert(user, at: index)
                                        } else {
                                            hydratedUsers.append(user)
                                        }
                                    }
                                    if hydratedUsers.count == allUniqueUsersIDsToBeHydrated.count {
                                        // Now that we hydrated all the users that are in the friendships table,
                                        // related to the current user (user1 or user2), we send back the full response
                                        // First we add the friends
                                        let friendships = friendsIDs.compactMap({ (friendID) -> ATCChatFriendship? in
                                            if let otherUser = self.user(for: friendID, in: hydratedUsers) {
                                                return ATCChatFriendship(currentUser: viewer, otherUser: otherUser, type: .mutual)
                                            }
                                            return nil
                                        })
                                        // Then we add the inbound requests
                                        let inboundRequests = inboundRequestsUserIDs.compactMap({ (userID) -> ATCChatFriendship? in
                                            if let otherUser = self.user(for: userID, in: hydratedUsers) {
                                                return ATCChatFriendship(currentUser: viewer, otherUser: otherUser, type: .inbound)
                                            }
                                            return nil
                                        })
                                        // Then we add the outbound requests
                                        let outboundRequests = outboundRequestsUserIDs.compactMap({ (userID) -> ATCChatFriendship? in
                                            if let otherUser = self.user(for: userID, in: hydratedUsers) {
                                                return ATCChatFriendship(currentUser: viewer, otherUser: otherUser, type: .outbound)
                                            }
                                            return nil
                                        })
                                        completion(friendships + inboundRequests + outboundRequests)
                                    }
                                }
                            }
                            self.allFriendListeners.append(friendListener)
                        } else {
                            usersRef.document(userID).getDocument(completion: { (document, error) in
                                if let userDict = document?.data() {
                                    let user = ATCUser(representation: userDict)
                                    serialQueue.sync {
                                        hydratedUsers.append(user)
                                    }
                                    if hydratedUsers.count == allUniqueUsersIDsToBeHydrated.count {
                                        // Now that we hydrated all the users that are in the friendships table,
                                        // related to the current user (user1 or user2), we send back the full response
                                        // First we add the friends
                                        let friendships = friendsIDs.compactMap({ (friendID) -> ATCChatFriendship? in
                                            if let otherUser = self.user(for: friendID, in: hydratedUsers) {
                                                return ATCChatFriendship(currentUser: viewer, otherUser: otherUser, type: .mutual)
                                            }
                                            return nil
                                        })
                                        // Then we add the inbound requests
                                        let inboundRequests = inboundRequestsUserIDs.compactMap({ (userID) -> ATCChatFriendship? in
                                            if let otherUser = self.user(for: userID, in: hydratedUsers) {
                                                return ATCChatFriendship(currentUser: viewer, otherUser: otherUser, type: .inbound)
                                            }
                                            return nil
                                        })
                                        // Then we add the outbound requests
                                        let outboundRequests = outboundRequestsUserIDs.compactMap({ (userID) -> ATCChatFriendship? in
                                            if let otherUser = self.user(for: userID, in: hydratedUsers) {
                                                return ATCChatFriendship(currentUser: viewer, otherUser: otherUser, type: .outbound)
                                            }
                                            return nil
                                        })
                                        
                                        completion(friendships + inboundRequests + outboundRequests)
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    private func user(for id: String, in users: [ATCUser]) -> ATCUser? {
        for user in users {
            if user.uid == id {
                return user
            }
        }
        return nil
    }
    
    func fetchUsers(viewer: ATCUser, completion: @escaping (_ friends: [ATCUser]) -> Void) {
        reportingManager.userIDsBlockedOrReported(by: viewer) { (illegalUserIDsSet) in
            let usersRef = Firestore.firestore().collection("users")
            usersRef.getDocuments { (querySnapshot, error) in
                if error != nil {
                    return
                }
                guard let querySnapshot = querySnapshot else {
                    return
                }
                var users: [ATCUser] = []
                let documents = querySnapshot.documents
                for document in documents {
                    let data = document.data()
                    let user = ATCUser(representation: data)
                    if let userID = user.uid {
                        if userID != viewer.uid && !illegalUserIDsSet.contains(userID) {
                            users.append(user)
                        }
                    }
                }
                completion(users)
            }
        }
    }
    
    func sendFriendRequest(viewer: ATCUser, to user: ATCUser, completion: @escaping () -> Void) {
        guard let u1 = viewer.uid, let u2 = user.uid else { return }
        
        let friendshipRef = Firestore.firestore().collection("friendships")
        friendshipRef.addDocument(data: [
            "user1" : u1,
            "user2" : u2
        ]) { (error) in
            self.postGraphUpdateNotification()
            completion()
        }
    }
    
    func acceptFriendRequest(viewer: ATCUser, from user: ATCUser, completion: @escaping () -> Void) {
        guard let uid = viewer.uid, let user2UID = user.uid else { return }
        let friendshipRef = Firestore.firestore().collection("friendships")
        friendshipRef.addDocument(data: ["user1" : uid,
                                         "user2" : user2UID]) { (error) in
                                            self.postGraphUpdateNotification()
                                            self.postGraphUpdateNotification()
                                            completion()
        }
    }
    
    func cancelFriendRequest(viewer: ATCUser, to user: ATCUser, completion: @escaping () -> Void) {
        guard let uid = viewer.uid, let user2UID = user.uid else { return }
        let friendshipRef = Firestore.firestore()
            .collection("friendships")
            .whereField("user1", isEqualTo: uid)
            .whereField("user2", isEqualTo: user2UID)
        
        friendshipRef.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion()
                return
            }
            snapshot.documents.forEach({ (document) in
                Firestore.firestore().collection("friendships").document(document.documentID).delete(completion: { (error) in
                    self.postGraphUpdateNotification()
                })
            })
            completion()
        }
    }
    
    func postGraphUpdateNotification() {
        NotificationCenter.default.post(name: kSocialGraphDidUpdateNotificationName, object: nil)
    }
}
