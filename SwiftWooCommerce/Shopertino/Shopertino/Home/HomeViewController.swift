//
//  HomeViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class HomeViewController: ATCGenericCollectionViewController {

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         dsProvider: ShopertinoDataSourceProvider) {

        let layout = ATCLiquidCollectionViewLayout()
        let homeConfig = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: true,
                                                                         pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                         collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                         collectionViewLayout: layout,
                                                                         collectionPagingEnabled: false,
                                                                         hideScrollIndicators: true,
                                                                         hidesNavigationBar: false,
                                                                         headerNibName: nil,
                                                                         scrollEnabled: true,
                                                                         uiConfig: uiConfig,
                                                                         emptyViewModel: nil)
        super.init(configuration: homeConfig)
        self.title = "Shopertino".localizedInApp

        let topCategoriesVC = TopCategoriesViewController(dsProvider: dsProvider, uiConfig: uiConfig)
        let topCategoriesModel = ATCCarouselViewModel(title: nil,
                                                      viewController: topCategoriesVC,
                                                      cellHeight: 90)
        topCategoriesModel.parentViewController = self

        let mainCarouselVC = ProductCarouselViewController(dsProvider: dsProvider,
                                                           uiConfig: uiConfig)
        let mainCarouselViewModel = ATCCarouselViewModel(title: "New Arrivals".localizedInApp,
                                                         viewController: mainCarouselVC,
                                                         config: ATCCarouselViewModelConfiguration(titleAlignment: .center),
                                                         cellHeight: 500)
        mainCarouselViewModel.parentViewController = self

        let featuredProductsVC = HorizontalProductsViewController(dsProvider: dsProvider,
                                                                  category: dsProvider.featuredCategory,
                                                                  uiConfig: uiConfig)
        let featuredProductsVM = ATCCarouselViewModel(title: "Featured".localizedInApp,
                                                      viewController: featuredProductsVC,
                                                      cellHeight: 340)
        featuredProductsVM.parentViewController = self

        let bestSellersProductsVC = ProductsViewController(dsProvider: dsProvider,
                                                           category: dsProvider.gridProductsCategory,
                                                           scrollEnabled: false,
                                                           uiConfig: uiConfig)
        let gridViewModel = ATCGridViewModel(title: "Best Sellers".localizedInApp,
                                             viewController: bestSellersProductsVC,
                                             cellHeight: 700,
                                             pageControlEnabled: false,
                                             callToAction: "Browse all".localizedInApp) {[weak self] in
                                                guard let `self` = self else { return }
                                                let vc = ProductsViewController(dsProvider: dsProvider,
                                                                                category: dsProvider.gridProductsCategory,
                                                                                uiConfig: uiConfig)
                                                self.navigationController?.pushViewController(vc, animated: true)
        }
        gridViewModel.parentViewController = self
        self.use(adapter: ATCGridViewRowAdapter(uiConfig: uiConfig), for: "ATCGridViewModel")

        let objects: [ATCGenericBaseModel] = [topCategoriesModel,
                                              ATCDivider(),
                                              mainCarouselViewModel,
                                              featuredProductsVM,
                                              gridViewModel];
        let dataSource = ATCGenericLocalHeteroDataSource(items: objects)

        self.genericDataSource = dataSource
        self.use(adapter: ATCDividerRowAdapter(titleFont: uiConfig.boldLargeFont, minHeight: 10), for: "ATCDivider")
        self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateProductsCollection), name: kShopertinoCollectionDidUpdateNotificationName, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func didUpdateProductsCollection() {
        self.genericDataSource?.loadFirst()
    }
}
