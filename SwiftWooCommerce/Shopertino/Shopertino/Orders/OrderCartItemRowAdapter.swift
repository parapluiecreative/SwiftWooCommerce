//
//  OrderCartItemRowAdapter.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class OrderCartItemRowAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let item = object as? ATCShoppingCartItem, let cell = cell as? OrderCartItemCollectionViewCell else { return }

        cell.imageView.kf.setImage(with: URL(string: item.product.cartImageURLString))
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.layer.masksToBounds = true
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = 8

        cell.titleLabel.text = item.product.cartTitle
        cell.titleLabel.textColor = uiConfig.mainTextColor
        cell.titleLabel.font = uiConfig.regularFont(size: 14)
        cell.containerView.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.backgroundColor = UIColor.darkModeColor(hexString: "#fafafa")
        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    func cellClass() -> UICollectionViewCell.Type {
        return OrderCartItemCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width, height: 80)
    }
}
