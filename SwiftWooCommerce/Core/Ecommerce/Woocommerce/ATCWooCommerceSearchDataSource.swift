//
//  ATCWooCommerceSearchDataSource.swift
//  Shopertino
//
//  Created by Mac  on 20/11/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCWooCommerceSearchDataSource<T: ATCGenericSearchable & ATCGenericBaseModel>: ATCGenericSearchViewControllerDataSource {
    
    var viewer: ATCUser?
    weak var delegate: ATCGenericSearchViewControllerDataSourceDelegate?
    var products: [Product] = []
    let apiManager: WooCommerceAPIManager
    let categoryId: String?

    init(apiManager: WooCommerceAPIManager, categoryId: String? = nil) {
        self.apiManager = apiManager
        self.categoryId = categoryId
    }

    var currentSearchTask: URLSessionDataTask?
    
    func search(text: String?) {
        if let currentSearchTask = currentSearchTask {
            currentSearchTask.cancel()
        }
        let task = self.apiManager.fetchProducts(categoryId: categoryId) { (products) in
            if let products = products {
                if let text = text {
                    self.products = products.filter({$0.matches(keyword: text)})
                }
                self.delegate?.dataSource(self as! ATCGenericSearchViewControllerDataSource, didFetchResults: self.products)
            } else {
                self.products = []
                self.delegate?.dataSource(self as! ATCGenericSearchViewControllerDataSource, didFetchResults: [])
            }
        }
        currentSearchTask = task
    }

    func update(completion: @escaping () -> Void) {}
}
