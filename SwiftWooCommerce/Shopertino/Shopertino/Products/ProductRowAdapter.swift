//
//  ProductRowAdapter.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ProductRowAdapter: ATCGenericCollectionRowAdapter {

    private let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let product = object as? ProductTypeProtocol, let cell = cell as? ProductCollectionViewCell else { return }
        cell.imageView.kf.setImage(with: URL(string: product.imageURLString))
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.layer.masksToBounds = true
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = 7

        cell.titleLabel.text = product.title
        cell.titleLabel.textColor = uiConfig.mainSubtextColor
        cell.titleLabel.font = uiConfig.regularFont(size: 12)

        cell.priceLabel.text = "$" + (Double(product.price) ?? 0.0).twoDecimalsString()
        cell.priceLabel.textColor = uiConfig.mainTextColor
        cell.priceLabel.font = uiConfig.boldFont(size: 14)

        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        
        cell.clipsToBounds = true
        cell.containerView.clipsToBounds = true
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ProductCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: 150, height: 290)
    }
}
