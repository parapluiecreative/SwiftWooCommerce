//
//  ATCFirebaseSearchDataSource.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/2/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCFirebaseSearchDataSource<T: ATCGenericSearchable & ATCGenericBaseModel>: ATCGenericSearchViewControllerDataSource {

    var viewer: ATCUser?
    weak var delegate: ATCGenericSearchViewControllerDataSourceDelegate?
    let tableName: String
    let limit: Int?
    init(tableName: String, limit: Int? = nil) {
        self.tableName = tableName
        self.limit = limit
    }

    func search(text: String?) {
        let ref: Query = Firestore.firestore().collection(tableName)
        ref.getDocuments {[weak self] (querySnapshot, error) in
            guard let `self` = self else { return }
            if error != nil {
                return
            }
            guard let querySnapshot = querySnapshot else {
                return
            }
            var items: [T] = []
            let documents = querySnapshot.documents
            for document in documents {
                let data = document.data()
                items.append(T(jsonDict: data))
            }
            if let limit = self.limit {
                items = Array(items.prefix(limit))
            }
            if let text = text {
                items = items.filter({$0.matches(keyword: text)})
            }
            self.delegate?.dataSource(self as! ATCGenericSearchViewControllerDataSource, didFetchResults: items)
        }
    }
    
    func update(completion: @escaping () -> Void) {}
}
