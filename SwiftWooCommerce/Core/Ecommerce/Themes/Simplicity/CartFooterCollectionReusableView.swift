//
//  CartFooterCollectionReusableView.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/22/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class CartFooterCollectionReusableView: UICollectionReusableView {
    @IBOutlet var totalPriceTextLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

    func configure(totalPrice: Double, uiEcommerceConfig: ATCUIConfigurationProtocol) {
        priceLabel.text = "$" + totalPrice.twoDecimalsString()
        priceLabel.font = uiEcommerceConfig.cartScreenFooterPriceFont
        priceLabel.textColor = uiEcommerceConfig.cartScreenFooterPriceColor

        totalPriceTextLabel.text = "Total".localizedEcommerce
        totalPriceTextLabel.font = uiEcommerceConfig.cartScreenFooterTotalPriceTextFont
        totalPriceTextLabel.textColor = uiEcommerceConfig.cartScreenFooterTotalPriceTextColor
    }
}
