//
//  CategoryRowAdapter.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class CategoryRowAdapter: ATCGenericCollectionRowAdapter {

    private let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let category = object as? Category, let cell = cell as? CategoryCollectionViewCell else { return }
        cell.imageView.kf.setImage(with: URL(string: category.imageURLString))
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.layer.masksToBounds = true
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = 10
        cell.imageView.alpha = 0.35

        cell.titleLabel.text = category.title.uppercased()
        cell.titleLabel.textColor = .white
        cell.titleLabel.font = uiConfig.boldFont(size: 16)
        cell.titleLabel.alpha = 1
        cell.titleLabel.backgroundColor = .clear

        cell.containerView.backgroundColor = UIColor(hexString: "#000000", alpha: 1)
        cell.containerView.layer.cornerRadius = 10

        cell.clipsToBounds = true
    }

    func cellClass() -> UICollectionViewCell.Type {
        return CategoryCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width - 30, height: 105)
    }
}
