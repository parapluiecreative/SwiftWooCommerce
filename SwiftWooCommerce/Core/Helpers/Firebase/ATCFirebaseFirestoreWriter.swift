//
//  ATCFirebaseFirestoreWriter.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/13/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ATCFirebaseFirestoreWriter {
    let tableName: String

    init(tableName: String) {
        self.tableName = tableName
    }

    func save(_ representation: [String: Any], completion: @escaping () -> Void) {
        var dictionary = representation
        let newDocRef = Firestore.firestore().collection(self.tableName).document()
        dictionary["id"] = newDocRef.documentID
        newDocRef.setData(dictionary) { (error) in
            completion()
        }
    }
}
