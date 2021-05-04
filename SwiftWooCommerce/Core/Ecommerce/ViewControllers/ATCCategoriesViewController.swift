//
//  CategoriesViewController.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 8/29/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCCategoriesViewController: UIViewController {

    let categoriesVC: ATCGenericCollectionViewController
    let uiEcommerceConfig: ATCUIConfigurationProtocol
    init(dsProvider: ATCEcommerceDataSourceProvider,
         uiConfig: ATCUIGenericConfigurationProtocol,
         cartManager: ATCShoppingCartManager,
         uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.uiEcommerceConfig = uiEcommerceConfig
        categoriesVC = ATCCategoriesCollectionViewControllerFactory.categoriesVC(uiConfig: uiConfig,
                                                                                 cartManager: cartManager,
                                                                                 dsProvider: dsProvider, uiEcommerceConfig: uiEcommerceConfig)
        categoriesVC.genericDataSource = dsProvider.categoriesDataSource
        let size = { (bounds: CGRect) in
            return CGSize(width: bounds.width / 2 - 3 * uiEcommerceConfig.categoryScreenCellPadding,
                          height: uiEcommerceConfig.categoryScreenCellHeight)
        }
        categoriesVC.use(adapter: ATCCategoryRowAdapter(uiEcommerceConfig: uiEcommerceConfig, size: size), for: "Category")
        super.init(nibName: nil, bundle: nil)

        title = uiEcommerceConfig.categoriesTitle
//        tabBarItem = UITabBarItem(title: uiEcommerceConfig.categoriesTabBarItemTitle, image: uiEcommerceConfig.categoriesTabBarItemImage, selectedImage: uiEcommerceConfig.categoriesTabBarItemSelectedImage).tabBarWithNoTitle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewControllerWithView(categoriesVC)
    }
}
