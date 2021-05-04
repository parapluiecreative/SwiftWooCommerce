//
//  CategoriesViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class CategoriesViewController: ATCGenericCollectionViewController {
    init(dsProvider: ATCEcommerceDataSourceProvider,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        let layout = ATCCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let emptyViewModel = CPKEmptyViewModel(image: nil, title: "No Categories".localizedInApp, description: "No categories found.".localizedInApp, callToAction: nil)
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
            if let category = model as? Category {
                let vc = ProductsViewController(dsProvider: dsProvider, category: category, uiConfig: uiConfig)
                nav?.pushViewController(vc, animated: true)
            }
        }
        self.genericDataSource = dsProvider.categoriesDataSource
        self.use(adapter: CategoryRowAdapter(uiConfig: uiConfig), for: "Category")
        self.title = "Shop".localizedInApp
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
