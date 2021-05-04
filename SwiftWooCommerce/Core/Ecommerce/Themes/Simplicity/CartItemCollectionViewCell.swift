//
//  CartItemCollectionViewCell.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/8/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Kingfisher
import UIKit

class CartItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet var cartPriceLabel: UILabel!
    @IBOutlet var cartItemTitleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!

    func configure(item: ATCShoppingCartItem, uiConfig: ATCUIGenericConfigurationProtocol) {
        cartPriceLabel.text = "$" + item.product.cartPrice.twoDecimalsString()
        cartItemTitleLabel.text = item.product.cartTitle
        countLabel.text = "  " + String(item.quantity) + "  "

        cartPriceLabel.font = uiConfig.regularFont(size: 16)

        cartItemTitleLabel.font = uiConfig.regularFont(size: 16)

        countLabel.font = uiConfig.regularSmallFont
        countLabel.layer.borderColor = UIColor(hexString: "#c0c0c2").cgColor
        countLabel.layer.borderWidth = 1.0
    }
}
