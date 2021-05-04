//
//  ATCFirebaseMapDataSource.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/2/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCFirebaseMapDataSource<T: ATCMapAnnotationViewModel & ATCGenericBaseModel>: ATCMapDataSource {
    weak var delegate: ATCMapDataSourceDelegate?
    let tableName: String
    let conditions: [String: Any]
    let additionalFilterBlock: (([T]) -> [T])?

    init(tableName: String,
         conditions: [String: Any] = [:],
         additionalFilterBlock: (([T]) -> [T])? = nil) {
        self.tableName = tableName
        self.conditions = conditions
        self.additionalFilterBlock = additionalFilterBlock
    }

    func load() {
        var ref: Query = Firestore.firestore().collection(tableName)
        conditions.forEach { (arg0) in
            let (key, value) = arg0
            ref = ref.whereField(key, isEqualTo: value)
        }

        ref.getDocuments {[weak self] (querySnapshot, error) in
            guard let `self` = self else { return }
            if let _ = error {
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
                items = additionalFilterBlock(items)
            }
            self.delegate?.dataSource(self, didLoadItems: items)
        }
    }
}
