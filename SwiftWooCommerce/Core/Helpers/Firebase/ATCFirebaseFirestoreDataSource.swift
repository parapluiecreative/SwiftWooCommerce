//
//  ATCFirebaseFirestoreDataSource.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/1/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCFirebaseFirestoreDataSource<T: ATCGenericBaseModel>: ATCGenericCollectionViewControllerDataSource {
    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var items: [T] = []
    let tableName: String
    let conditions: [String: Any]
    let limit: Int?
    let additionalFilterBlock: (([T]) -> [T])?

    init(tableName: String,
         conditions: [String: Any] = [:],
         limit: Int? = nil,
         additionalFilterBlock: (([T]) -> [T])? = nil) {
        self.tableName = tableName
        self.additionalFilterBlock = additionalFilterBlock
        self.conditions = conditions
        self.limit = limit
    }

    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < items.count {
            return items[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return items.count
    }

    func loadFirst() {
        var ref: Query = Firestore.firestore().collection(tableName)
        conditions.forEach { (arg0) in
            let (key, value) = arg0
            ref = ref.whereField(key, isEqualTo: value)
        }

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
            if let additionalFilterBlock = self.additionalFilterBlock {
                self.items = additionalFilterBlock(items)
            } else {
                self.items = items
            }
            if let limit = self.limit {
                self.items = Array(self.items.prefix(limit))
            }
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: items)
        }
    }

    func loadBottom() {}

    func loadTop() {}
}
