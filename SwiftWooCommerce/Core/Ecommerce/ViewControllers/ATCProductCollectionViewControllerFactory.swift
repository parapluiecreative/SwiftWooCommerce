//
//  ProductCollectionViewControllerFactory.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/11/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCProductCollectionViewControllerFactory {
    class func vc(title: String,
                  dataSource: ATCGenericCollectionViewControllerDataSource,
                  uiConfig: ATCUIGenericConfigurationProtocol,
                  cartManager: ATCShoppingCartManager,
                  uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCGenericCollectionViewController {
        let productRowAdapter = ATCProductRowAdapter(uiConfig: uiConfig)
        let layout = ATCLiquidCollectionViewLayout()
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Items".localizedEcommerce,
                                               description: "There are currently no products. All products added by the selected vendor will be displayed here.".localizedEcommerce,
                                               callToAction: nil)
        let productVCConfiguration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                                     pullToRefreshTintColor: .white,
                                                                                     collectionViewBackgroundColor: uiEcommerceConfig.productScreenBackgroundColor,
                                                                                     collectionViewLayout: layout,
                                                                                     collectionPagingEnabled: false,
                                                                                     hideScrollIndicators: false,
                                                                                     hidesNavigationBar: false,
                                                                                     headerNibName: nil,
                                                                                     scrollEnabled: true,
                                                                                     uiConfig: uiConfig,
                                                                                     emptyViewModel: emptyViewModel)

        let productsVC = ATCGenericCollectionViewController(configuration: productVCConfiguration)
        productsVC.selectionBlock = { (navigationController, object, index) in
            if let product = object as? Product {
                let productDetailsVC = ATCProductDetailsViewControllerFactory().productDetailsVC(product: product,
                                                                                                 uiConfig: uiConfig,
                                                                                                 cartManager: cartManager,
                                                                                                 uiEcommerceConfig: uiEcommerceConfig)
//                navigationController?.pushViewController(productVC, animated: true)
                productsVC.present(productDetailsVC, animated: true, completion: nil)
            }
        }

        productsVC.genericDataSource = dataSource
        productsVC.use(adapter: productRowAdapter, for: "Product")
        productsVC.title = title
        return productsVC
    }
}
