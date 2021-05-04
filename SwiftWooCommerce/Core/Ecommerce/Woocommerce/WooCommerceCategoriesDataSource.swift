//
//  WooCommerceCategoriesDataSource.swift
//  Shopertino
//
//  Created by Florian Marcu on 9/3/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class WooCommerceCategoriesDataSource: ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var categories: [Category] = []
    var apiManager: WooCommerceAPIManager
    init(apiManager: WooCommerceAPIManager) {
        self.apiManager = apiManager
    }

    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < categories.count {
            return categories[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return categories.count
    }

    func loadFirst() {
        self.apiManager.fetchCategories { (jsonList) in
            if let jsonList = jsonList {
                var categories: [Category] = []
                for dict in jsonList {
                    let category = Category(wooCommerceDict: dict)
                    categories.append(category)
                }
                self.categories = categories
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: categories)
            } else {
                self.categories = []
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: [])
            }
        }
    }

    func loadBottom() {}
    func loadTop() {}
}
