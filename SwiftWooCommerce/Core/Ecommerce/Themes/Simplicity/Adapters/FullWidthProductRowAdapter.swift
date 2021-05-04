//
//  FullWidthProductAdapter.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/19/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class FullWidthProductRowAdapter: ATCGenericCollectionRowAdapter {

    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    
    init(uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.uiEcommerceConfig = uiEcommerceConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let product = object as? Product, let cell = cell as? FullWidthProductCollectionViewCell else { return }
        cell.productImageview.kf.setImage(with: URL(string: product.imageURLString))
        cell.productImageview.contentMode = .scaleAspectFill
        cell.productImageview.backgroundColor = .white
        cell.productImageview.clipsToBounds = true

        let textColor = UIColor(hexString: "#222").darkModed
        cell.productTitleLabel.text = product.title
        cell.productTitleLabel.font = uiEcommerceConfig.regularMediumSizeFont
        cell.productTitleLabel.textColor = textColor

        cell.productPriceLabel.text = "$" + product.price
        cell.productPriceLabel.font = uiEcommerceConfig.regularMediumSizeFont
        cell.productPriceLabel.textColor = textColor

        cell.containerView.backgroundColor = .clear
    }

    func cellClass() -> UICollectionViewCell.Type {
        return FullWidthProductCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width,
                      height: 230)
    }
}
