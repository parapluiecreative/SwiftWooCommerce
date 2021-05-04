//
//  ATCSearchViewControllerFactory.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

class ATCSearchViewControllerFactory {
    static func localSearchViewController(uiConfig: ATCUIGenericConfigurationProtocol,
                                          dsProvider: ATCEcommerceDataSourceProvider,
                                          uiEcommerceConfig: ATCUIConfigurationProtocol) -> ATCGenericSearchViewController<Product> {
        let vc = ATCGenericSearchViewController<Product>(configuration: ATCGenericSearchViewControllerConfiguration(searchBarPlaceholderText: "Search Products...".localizedEcommerce, uiConfig: uiConfig, cellPadding: 0.0))
        vc.searchDataSource = dsProvider.searchDataSource
        vc.use(adapter: ATCProductRowAdapter(uiConfig: uiConfig), for: "Product")
        return vc
    }
}
