//
//  WishlistViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/13/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class WishlistViewController: ATCGenericCollectionViewController {
    let savedStore = ATCDiskPersistenceStore(key: "com.shopertino.wishlist")

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider) {
        let layout = ATCLiquidCollectionViewLayout()
        let emptyViewModel = CPKEmptyViewModel(image: nil, title: "No Products".localizedInApp, description: "No products were added to the wishlist.".localizedInApp, callToAction: nil)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: .gray,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: emptyViewModel)
        super.init(configuration: configuration) { (nav, model, index) in
            if let product = model as? Product {
                let vc = ProductDetailsViewController(product: product,
                                                      cartManager: ShopertinoHostViewController.cartManager,
                                                      user: ShopertinoHostViewController.user,
                                                      placeOrderManager: dsProvider.placeOrderManager,
                                                      uiConfig: uiConfig,
                                                      dsProvider: dsProvider)
                nav?.present(vc, animated: true, completion: nil)
            }
        }
        if let products = savedStore.retrieve() as? [Product] {
            self.genericDataSource = ATCGenericLocalHeteroDataSource(items: products)
        }
        self.use(adapter: ProductRowAdapter(uiConfig: uiConfig), for: "Product")
        self.title = "My Wishlist".localizedInApp
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let products = savedStore.retrieve() as? [Product] {
            self.genericDataSource = ATCGenericLocalHeteroDataSource(items: products)
            self.genericDataSource?.loadFirst()
        }
    }
}
