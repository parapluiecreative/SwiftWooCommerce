//
//  ATCCategoriesCollectionViewControllerFactory.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/19/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ATCCategoriesCollectionViewControllerFactory {
    static func categoriesVC(uiConfig: ATCUIGenericConfigurationProtocol,
                             cartManager: ATCShoppingCartManager,
                             dsProvider: ATCEcommerceDataSourceProvider,
                             uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCGenericCollectionViewController {
        let cellPadding = uiEcommerceConfig.categoryScreenCellPadding;
        let layout = ATCLiquidCollectionViewLayout(cellPadding: cellPadding)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: .white,
                                                                            collectionViewBackgroundColor: uiEcommerceConfig.categoryScreenBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: true,
                                                                            hideScrollIndicators: false,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)

        return self.categoriesVC(config: configuration,
                                 uiConfig: uiConfig,
                                 cartManager: cartManager,
                                 dsProvider: dsProvider,
                                 uiEcommerceConfig: uiEcommerceConfig)
    }

    static func fullWidthCategoriesVC(uiConfig: ATCUIGenericConfigurationProtocol,
                                      dsProvider: ATCEcommerceDataSourceProvider,
                                      cartManager: ATCShoppingCartManager,
                                      uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCGenericCollectionViewController {
        let carouselLayout = ATCCollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.minimumInteritemSpacing = 0
        carouselLayout.minimumLineSpacing = 0
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: .white,
                                                                            collectionViewBackgroundColor: uiEcommerceConfig.categoryScreenBackgroundColor,
                                                                            collectionViewLayout: carouselLayout,
                                                                            collectionPagingEnabled: true,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)

        let categoriesVC = self.categoriesVC(config: configuration,
                                             uiConfig: uiConfig,
                                             cartManager: cartManager,
                                             dsProvider: dsProvider,
                                             uiEcommerceConfig: uiEcommerceConfig)
        categoriesVC.genericDataSource = dsProvider.categoriesDataSource
        let size = { (bounds: CGRect) in
            return CGSize(width: bounds.width,
                          height: bounds.height)
        }
        categoriesVC.use(adapter: ATCCategoryRowAdapter(uiEcommerceConfig: uiEcommerceConfig, size: size), for: "Category")
        return categoriesVC
    }

    static func storiesVC(uiConfig: ATCUIGenericConfigurationProtocol,
                          dsProvider: ATCEcommerceDataSourceProvider,
                          cartManager: ATCShoppingCartManager,
                          uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCGenericCollectionViewController {
        let vc = ATCViewControllerFactory.storiesViewController(dataSource: dsProvider.categoriesDataSource,
                                                                uiConfig: uiConfig,
                                                                selectionBlock: self.categorySelectionBlock(uiConfig: uiConfig,
                                                                                                            cartManager: cartManager,
                                                                                                            dsProvider: dsProvider,
                                                                                                            uiEcommerceConfig: uiEcommerceConfig))
        vc.use(adapter: ATCStoryAdapter(uiConfig: uiConfig), for: "Category")
        return vc
    }

    private static func categoriesVC(config: ATCGenericCollectionViewControllerConfiguration,
                                     uiConfig: ATCUIGenericConfigurationProtocol,
                                     cartManager: ATCShoppingCartManager,
                                     dsProvider: ATCEcommerceDataSourceProvider,
                                     uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCGenericCollectionViewController {
        return ATCGenericCollectionViewController(configuration: config,
                                                  selectionBlock: self.categorySelectionBlock(uiConfig: uiConfig,
                                                                                              cartManager: cartManager,
                                                                                              dsProvider: dsProvider, uiEcommerceConfig: uiEcommerceConfig))
    }

    private static func categorySelectionBlock(uiConfig: ATCUIGenericConfigurationProtocol,
                                               cartManager: ATCShoppingCartManager,
                                               dsProvider: ATCEcommerceDataSourceProvider,
                                               uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCollectionViewSelectionBlock {
        return { (navigationController, object, indexPath) in
            guard let category = object as? Category else { return }
            let dataSource = dsProvider.productsDataSource(for: category)
            let productsVC = ATCProductCollectionViewControllerFactory.vc(title: category.title,
                                                                          dataSource: dataSource,
                                                                          uiConfig: uiConfig,
                                                                          cartManager: cartManager,
                                                                          uiEcommerceConfig: uiEcommerceConfig)
            navigationController?.pushViewController(productsVC, animated: true)
        }
    }
}
