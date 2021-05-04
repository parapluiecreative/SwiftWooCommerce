//
//  WooCommerceProductsDataSource.swift
//  Shopertino
//
//  Created by Florian Marcu on 9/3/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class WooCommerceProductsDataSource: ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var products: [Product] = []
    let apiManager: WooCommerceAPIManager
    let categoryId: String?

    init(apiManager: WooCommerceAPIManager, categoryId: String? = nil) {
        self.apiManager = apiManager
        self.categoryId = categoryId
    }

    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < products.count {
            return products[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return products.count
    }

    func loadFirst() {
        self.apiManager.fetchProducts(categoryId: categoryId) { (products) in
            if let products = products {
                self.products = products
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: products)
            } else {
                self.products = []
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: [])
            }
        }
    }

    func loadBottom() {}
    func loadTop() {}
}
