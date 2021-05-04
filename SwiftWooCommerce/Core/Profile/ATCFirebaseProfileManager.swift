//
//  ATCChatProfileManager.swift
//  ChatApp
//
//  Created by Osama Naeem on 28/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ATCFirebaseProfileManager : ATCProfileManager {
    var usersListener: ListenerRegistration? = nil

    var delegate: ATCProfileManagerDelegate?
    
    func fetchProfile(for user: ATCUser) {
        self.delegate?.profileEditManager(self, didFetch: user)
    }
    
    func update(profile: ATCUser, email: String, firstName: String, lastName: String, phone: String) {
        let documentRef = Firestore.firestore().collection("users").document("\(profile.uid!)")
        
        documentRef.updateData([
            "firstName" : firstName,
            "lastName"  : lastName,
            "email"     : email,
            "phone"     : phone,
            "id"     : profile.uid!,
            "userID"    : profile.uid!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                self.delegate?.profileEditManager(self, didUpdateProfile: false)
            } else {
                print("Successfully updated")
                profile.firstName = firstName
                profile.lastName = lastName
                profile.email = email
                self.delegate?.profileEditManager(self, didUpdateProfile: true)
            }
        }
    }
    
    func updateUserPresence(profile: ATCUser, isOnline: Bool) {
        let documentRef = Firestore.firestore().collection("users").document("\(profile.uid!)")
        documentRef.updateData([
            "isOnline" : isOnline,
            "lastOnlineTimestamp": Date()
        ])
    }
}
