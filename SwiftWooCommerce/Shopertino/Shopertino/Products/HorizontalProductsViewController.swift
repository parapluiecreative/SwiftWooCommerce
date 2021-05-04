//
//  HorizontalProductsViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/30/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class HorizontalProductsViewController: ATCGenericCollectionViewController {
    init(dsProvider: ATCEcommerceDataSourceProvider,
         category: Category,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let emptyViewModel = CPKEmptyViewModel(image: nil, title: "No Products".localizedInApp, description: "There are no products available for purchase at this time.".localizedInApp, callToAction: nil)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
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
        self.genericDataSource = dsProvider.productsDataSource(for: category)
        self.use(adapter: ProductRowAdapter(uiConfig: uiConfig), for: "Product")
        self.title = category.title
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateProductsCollection), name: kShopertinoCollectionDidUpdateNotificationName, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func didUpdateProductsCollection() {
        self.genericDataSource?.loadFirst()
    }
}
