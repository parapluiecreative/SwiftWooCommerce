//
//  ATCAllAdminsFirebaseDataSource.swift
//  RestaurantApp
//
//  Copyright © 2020 iOS App Templates. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol ATCAllAdminsFirebaseDataSourceProtocol {
    func fetchAllAdmins(completion: @escaping (_ users: [ATCUser]) -> Void)
}

extension ATCAllAdminsFirebaseDataSourceProtocol {
    func fetchAllAdmins(completion: @escaping (_ users: [ATCUser]) -> Void){
        Firestore.firestore().collection("users").getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, error == nil else {
                completion([])
                return
            }
            /// Fetch users with the corresponding type - if isAdmin is true, fetch all admins. Otherwise, fetch all customers
            let admins = querySnapshot.documents
                .compactMap { ATCUser(jsonDict: $0.data()) }
                .filter { $0.isAdmin }
            completion(admins)
        }
    }
}
