//
//  ATCWooCommerceOrdersDataSource.swift
//  Shopertino
//
//  Created by Florian Marcu on 6/23/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

class ATCWooCommerceOrdersDataSource: ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var orders: [ATCOrder] = []

    let apiManager: WooCommerceAPIManager
    let viewer: ATCUser

    init(apiManager: WooCommerceAPIManager, viewer: ATCUser) {
        self.apiManager = apiManager
        self.viewer = viewer
    }

    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < orders.count {
            return orders[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return orders.count
    }

    func loadFirst() {
        self.apiManager.fetchOrders(email: viewer.email ?? "noemail") { [weak self] (jsonList) in
            guard let `self` = self else { return }
            if let jsonList = jsonList {
                var orders: [ATCOrder] = []
                for dict in jsonList {
                    let order = ATCOrder(wooCommerceDict: dict)
                    if (order.address?.email == self.viewer.email) {
                        orders.append(order)
                    }
                }
                self.orders = orders
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: orders)
            } else {
                self.orders = []
                self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: [])
            }
        }
    }

    func loadBottom() {}
    func loadTop() {}
}
