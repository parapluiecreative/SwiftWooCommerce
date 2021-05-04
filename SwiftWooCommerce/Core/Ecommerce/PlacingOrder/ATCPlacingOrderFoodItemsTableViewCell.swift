//
//  ATCPlacingOrderFoodItemsTableViewCell.swift
//  MultiVendorApp
//
//  Created by Mac  on 02/05/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

class ATCPlacingOrderFoodItemsTableViewCell: UITableViewCell {

    @IBOutlet var cartItemTitleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!

    func configure(item: ATCShoppingCartItem, uiConfig: ATCUIGenericConfigurationProtocol) {
        cartItemTitleLabel.text = item.product.cartTitle
        countLabel.text = "  " + String(item.quantity) + "  "

        cartItemTitleLabel.font = uiConfig.regularFont(size: 14)
        cartItemTitleLabel.textColor = uiConfig.mainTextColor
        
        countLabel.font = uiConfig.regularFont(size: 12)
        countLabel.textColor = uiConfig.mainTextColor
        
        countLabel.layer.borderColor = UIColor(hexString: "#c0c0c2").cgColor
        countLabel.layer.borderWidth = 1.0
    }
    
}
