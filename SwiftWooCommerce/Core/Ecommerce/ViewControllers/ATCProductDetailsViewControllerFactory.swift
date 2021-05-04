//
//  ProductDetailsViewControllerFactory.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/13/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

class ATCProductDetailsViewControllerFactory {
    func productDetailsVC(product: Product,
                          uiConfig: ATCUIGenericConfigurationProtocol,
                          cartManager: ATCShoppingCartManager,
                          uiEcommerceConfig: ATCUIConfigurationProtocol) -> ProductDetailsViewController {
        return ProductDetailsViewController(product: product,
                                            uiConfig: uiConfig,
                                            cartManager: cartManager,
                                            nibName: "ProductDetailsViewController",
                                            bundle: nil,
                                            uiEcommerceConfig: uiEcommerceConfig)
    }
}
