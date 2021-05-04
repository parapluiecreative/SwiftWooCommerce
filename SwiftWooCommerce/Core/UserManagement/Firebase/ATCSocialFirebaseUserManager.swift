//
//  ATCSocialFirebaseUserManager.swift
//  CryptoApp
//
//  Created by Florian Marcu on 6/29/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCSocialFirebaseUserManager: ATCSocialUserManagerProtocol {
    func fetchUser(userID: String, completion: @escaping (_ user: ATCUser?, _ error: Error?) -> Void) {
        let usersRef = Firestore.firestore().collection("users").whereField("id", isEqualTo: userID)
        usersRef.getDocuments { (querySnapshot, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            guard let querySnapshot = querySnapshot else {
                completion(nil, error)
                return
            }
            if let document = querySnapshot.documents.first {
                let data = document.data()
                let user = ATCUser(representation: data)
                completion(user, error)
            } else {
                completion(nil, error)
            }
        }
    }
}
