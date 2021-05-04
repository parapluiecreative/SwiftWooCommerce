//
//  CarouselProductRowAdapter.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/4/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class CarouselProductRowAdapter: ATCGenericCollectionRowAdapter {

    private let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let product = object as? Product, let cell = cell as? CarouselProductCollectionViewCell else { return }
        cell.imageView.kf.setImage(with: URL(string: product.imageURLString))
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.layer.masksToBounds = true
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = 7

        cell.titleLabel.text = product.title
        cell.titleLabel.textColor = uiConfig.mainTextColor
        cell.titleLabel.font = uiConfig.regularFont(size: 16)

        cell.priceLabel.text = "$" + (Double(product.price) ?? 0.0).twoDecimalsString()
        cell.priceLabel.textColor = uiConfig.mainSubtextColor
        cell.priceLabel.font = uiConfig.regularFont(size: 14)

        cell.imageContainerView.dropCupertinoShadow()

        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor

        cell.clipsToBounds = true
        cell.containerView.clipsToBounds = true
    }

    func cellClass() -> UICollectionViewCell.Type {
        return CarouselProductCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: 270, height: 450)
    }
}
