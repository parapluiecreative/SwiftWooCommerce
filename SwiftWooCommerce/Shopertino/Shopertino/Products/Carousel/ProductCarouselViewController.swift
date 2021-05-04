//
//  ProductCarouselViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/4/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ProductCarouselViewController: ATCGenericCollectionViewController {
    init(dsProvider: ShopertinoDataSourceProvider,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        let layout = CPKCarouselFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sideItemScale = 0.8
        layout.sideItemAlpha = 0.8
        layout.spacingMode = CPKCarouselFlowLayoutSpacingMode.fixed(spacing: 0)
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
        self.genericDataSource = dsProvider.productsDataSource(for: dsProvider.mainCarouselCategory)
        self.use(adapter: CarouselProductRowAdapter(uiConfig: uiConfig), for: "Product")
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateProductsCollection), name: kShopertinoCollectionDidUpdateNotificationName, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func genericCollectionViewControllerDataSource(_ dataSource: ATCGenericCollectionViewControllerDataSource, didLoadFirst objects: [ATCGenericBaseModel]) {
        super.genericCollectionViewControllerDataSource(dataSource, didLoadFirst: objects)
        if objects.count > 1 {
            self.collectionView.selectItem(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func didUpdateProductsCollection() {
        self.genericDataSource?.loadFirst()
    }
}
