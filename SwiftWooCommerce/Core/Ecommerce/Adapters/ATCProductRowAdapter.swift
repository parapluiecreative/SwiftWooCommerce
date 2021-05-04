//
//  ATCProductRowAdapter.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 10/15/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCProductRowAdapter: ATCGenericCollectionRowAdapter {

    private let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let product = object as? Product, let cell = cell as? ProductCollectionViewCell else { return }
        cell.containerView.backgroundColor = .clear
        
        cell.imageView.kf.setImage(with: URL(string: product.imageURLString))
        cell.imageView.contentMode = .scaleToFill
        cell.imageView.backgroundColor = .white
        cell.titleLabel.text = product.title
        cell.titleLabel.font = uiConfig.regularLargeFont
        cell.titleLabel.textColor = uiConfig.mainTextColor
        cell.priceLabel.text = "$" + product.price
        cell.priceLabel.font = uiConfig.regularFont(size: 16)
        cell.priceLabel.textColor = uiConfig.mainTextColor
        
        cell.containerView.backgroundColor = .clear
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ProductCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width,
                      height: 125)
    }
}
