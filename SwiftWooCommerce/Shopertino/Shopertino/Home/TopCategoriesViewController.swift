//
//  TopCategoriesViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class TopCategoriesViewController: ATCGenericCollectionViewController {
    init(dsProvider: ATCEcommerceDataSourceProvider,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let emptyViewModel = CPKEmptyViewModel(image: nil, title: "No Categories".localizedInApp, description: "No categories found.".localizedInApp, callToAction: nil)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: .white,
                                                                            collectionViewBackgroundColor: .white,
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
        self.use(adapter: TopCategoryRowAdapter(uiConfig: uiConfig), for: "Category")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
