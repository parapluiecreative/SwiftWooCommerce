//
//  ATCHomeCollectionViewController.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 4/25/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ATCHomeCollectionViewController: ATCGenericCollectionViewController {
    static func homeViewController(uiConfig: ATCUIGenericConfigurationProtocol,
                                   dsProvider: ATCEcommerceDataSourceProvider,
                                   cartManager: ATCShoppingCartManager,
                                   uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCHomeCollectionViewController {

        let categoriesVC = ATCCategoriesCollectionViewControllerFactory.fullWidthCategoriesVC(uiConfig: uiConfig,
                                                                                              dsProvider: dsProvider,
                                                                                              cartManager: cartManager,
                                                                                              uiEcommerceConfig: uiEcommerceConfig)
        let size = { (bounds: CGRect) in
            return CGSize(width: bounds.width,
                          height: 300)
        }
        categoriesVC.use(adapter: ATCCategoryRowAdapter(uiEcommerceConfig: uiEcommerceConfig, size: size), for: "Category")

        let categoriesCarousel = ATCCarouselViewModel(title: "Best Deals".localizedEcommerce,
                                                      viewController: categoriesVC,
                                                      cellHeight: 300,
                                                      pageControlEnabled: true)

        let storiesVC = ATCCategoriesCollectionViewControllerFactory.storiesVC(uiConfig: uiConfig,
                                                                               dsProvider: dsProvider,
                                                                               cartManager: cartManager,
                                                                               uiEcommerceConfig: uiEcommerceConfig)
        let storiesCarousel = ATCCarouselViewModel(title: "Popular Categories".localizedEcommerce,
                                                   viewController: storiesVC,
                                                   cellHeight: 160)

        let layout = ATCLiquidCollectionViewLayout()
        let homeConfig = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: true,
                                                                         pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                         collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                         collectionViewLayout: layout,
                                                                         collectionPagingEnabled: false,
                                                                         hideScrollIndicators: false,
                                                                         hidesNavigationBar: false,
                                                                         headerNibName: nil,
                                                                         scrollEnabled: true,
                                                                         uiConfig: uiConfig,
                                                                         emptyViewModel: nil)
        let homeVC = ATCHomeCollectionViewController(configuration: homeConfig, selectionBlock: { (navigationController, object, indexPath) in
            if let product = object as? Product {
                let productVC = ATCProductDetailsViewControllerFactory().productDetailsVC(product: product,
                                                                                          uiConfig: uiConfig,
                                                                                          cartManager: cartManager, uiEcommerceConfig: uiEcommerceConfig)
                navigationController?.pushViewController(productVC, animated: true)
            }
        })
        homeVC.title = "Home".localizedCore

        let productsConfig = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: true,
                                                                             pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                             collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                             collectionViewLayout: ATCLiquidCollectionViewLayout(),
                                                                             collectionPagingEnabled: false,
                                                                             hideScrollIndicators: false,
                                                                             hidesNavigationBar: false,
                                                                             headerNibName: nil,
                                                                             scrollEnabled: true,
                                                                             uiConfig: uiConfig,
                                                                             emptyViewModel: nil)
        let productVC = ATCGenericCollectionViewController(configuration: productsConfig) {  (navigationController, object, indexPath) in
            if let product = object as? Product {
                let productVC = ATCProductDetailsViewControllerFactory().productDetailsVC(product: product,
                                                                                          uiConfig: uiConfig,
                                                                                          cartManager: cartManager,
                                                                                          uiEcommerceConfig: uiEcommerceConfig)
                navigationController?.pushViewController(productVC, animated: true)
            }
        }
        productVC.genericDataSource = dsProvider.homeProductsDataSource
        productVC.use(adapter: FullWidthProductRowAdapter(uiEcommerceConfig: uiEcommerceConfig), for: "Product")

        let productsVM = ATCViewControllerContainerViewModel(viewController: productVC,
                                                             subcellHeight: 230)
        productsVM.parentViewController = homeVC

        var objects: [ATCGenericBaseModel] = [];
        objects.append(contentsOf: [storiesCarousel, categoriesCarousel])
        objects.append(ATCDivider("Most Popular".localizedEcommerce))
        objects.append(productsVM)
        let dataSource = ATCGenericLocalHeteroDataSource(items: objects)

        homeVC.genericDataSource = dataSource
        homeVC.use(adapter: ATCDividerRowAdapter(titleFont: uiConfig.boldLargeFont,
                                                 minHeight: 70,
                                                 titleColor: uiConfig.mainTextColor), for: "ATCDivider")
        homeVC.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
        categoriesCarousel.parentViewController = homeVC
        storiesCarousel.parentViewController = homeVC
        return homeVC
    }
}
