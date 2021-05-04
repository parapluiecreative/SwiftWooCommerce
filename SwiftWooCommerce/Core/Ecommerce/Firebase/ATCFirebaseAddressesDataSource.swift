//
//  ATCFirebaseAddressesDataSource.swift
//  MultiVendorApp
//
//  Created by Mayil Kannan on 11/01/21.
//  Copyright © 2021 Instamobile. All rights reserved.
//

import FirebaseFirestore
import Foundation

class ATCFirebaseAddressesDataSource: ATCGenericCollectionViewControllerDataSource {
    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var items: [ATCAddress] = []
    let tableName: String
    let conditions: [String: Any]
    let limit: Int?
    let additionalFilterBlock: (([ATCAddress]) -> [ATCAddress])?

    init(tableName: String,
         conditions: [String: Any] = [:],
         limit: Int? = nil,
         additionalFilterBlock: (([ATCAddress]) -> [ATCAddress])? = nil) {
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
            if let document = querySnapshot.documents.first {
                var items: [ATCAddress] = []
                if let shippingAddresses = document.data()["shippingAddress"] as? NSDictionary {
                    for shippingAddress in shippingAddresses.allKeys {
                        if let shippingAddress = shippingAddresses[shippingAddress] as? [String : Any] {
                            items.append(ATCAddress(jsonDict: shippingAddress))
                        }
                    }
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
            } else {
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: [])
            }
        }
    }

    func loadBottom() {}

    func loadTop() {}
}
