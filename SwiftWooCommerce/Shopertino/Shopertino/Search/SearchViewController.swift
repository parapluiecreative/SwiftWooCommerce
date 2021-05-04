//
//  SearchViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/14/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class SearchViewController: ATCGenericSearchViewController<Product> {

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider) {
        super.init(configuration: ATCGenericSearchViewControllerConfiguration(searchBarPlaceholderText: "Search Products...".localizedInApp,
                                                                              uiConfig: uiConfig,
                                                                              cellPadding: 0.0))
        self.searchDataSource = dsProvider.searchDataSource
        self.use(adapter: ProductRowAdapter(uiConfig: uiConfig), for: "Product")
        self.searchResultsController.selectionBlock = { (nav, object, index) in
            if let product = object as? Product {
                let productVC = ProductDetailsViewController(product: product,
                                                             cartManager: ShopertinoHostViewController.cartManager,
                                                             user: ShopertinoHostViewController.user,
                                                             placeOrderManager: dsProvider.placeOrderManager,
                                                             uiConfig: uiConfig,
                                                             dsProvider: dsProvider)
                self.navigationController?.present(productVC, animated: true, completion: nil)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
