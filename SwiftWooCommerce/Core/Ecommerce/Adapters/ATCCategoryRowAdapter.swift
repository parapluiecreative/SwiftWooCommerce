//
//  ATCCategoryRowAdapter.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/11/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCCategoryRowAdapter : ATCGenericCollectionRowAdapter {

    private let size: (CGRect) -> CGSize
    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    init(uiEcommerceConfig: ATCUIConfigurationProtocol,
         size: @escaping ((CGRect) -> CGSize)) {
        self.size = size
        self.uiEcommerceConfig = uiEcommerceConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let category = object as? ATCStoryViewModel, let cell = cell as? CategoryCollectionViewCell else { return }
            cell.imageView.kf.setImage(with: URL(string: category.imageURLString))
            cell.imageView.contentMode = .scaleAspectFill

            cell.titleLabel.text = category.title
            cell.titleLabel.textColor = uiEcommerceConfig.categoryScreenTitleLabelColor
            cell.titleLabel.font = uiEcommerceConfig.categoryScreenTitleFont
            cell.titleLabel.alpha = uiEcommerceConfig.categoryScreenTitleLabelAlpha
            cell.titleLabel.backgroundColor = .clear
    }

    func cellClass() -> UICollectionViewCell.Type {
        return CategoryCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return self.size(containerBounds)
    }
}
