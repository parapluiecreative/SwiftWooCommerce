//
//  ProductsViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/13/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ProductsViewController: ATCGenericCollectionViewController {
    init(dsProvider: ATCEcommerceDataSourceProvider,
         category: Category,
         scrollEnabled: Bool = true,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        let layout = ATCLiquidCollectionViewLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let emptyViewModel = CPKEmptyViewModel(image: nil, title: "No Products".localizedInApp, description: "There are no products available for purchase at this time.".localizedInApp, callToAction: nil)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: true,
                                                                            pullToRefreshTintColor: .gray,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: scrollEnabled,
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
