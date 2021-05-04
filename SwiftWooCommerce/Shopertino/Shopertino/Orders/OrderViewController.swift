//
//  OrderViewController.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/19.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class OrderViewController: ATCGenericCollectionViewController {
    var user: ATCUser? {
        didSet {
            if let user = user {
                self.genericDataSource = dsProvider.ordersDataSource(for: user, isPastOrder: false)
            }
        }
    }

    let dsProvider: ATCEcommerceDataSourceProvider
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         cartVC: ShoppingCartViewController,
         dsProvider: ATCEcommerceDataSourceProvider) {
        self.dsProvider = dsProvider
        let config = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                     pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                     collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                     collectionViewLayout: ATCCollectionViewFlowLayout(),
                                                                     collectionPagingEnabled: false,
                                                                     hideScrollIndicators: false,
                                                                     hidesNavigationBar: false,
                                                                     headerNibName: nil,
                                                                     scrollEnabled: true,
                                                                     uiConfig: uiConfig,
                                                                     emptyViewModel: nil)
        super.init(configuration: config)
        self.use(adapter: OrderRowAdapter(parentVC: self, uiConfig: uiConfig, cartVC: cartVC), for: "ATCOrder")
        self.title = "Orders".localizedInApp
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.genericDataSource?.loadFirst()
    }
}
