//
//  TopCategoryRowAdapter.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class TopCategoryRowAdapter: ATCGenericCollectionRowAdapter {
    private let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let category = object as? Category, let cell = cell as? TopCategoryCollectionViewCell else { return }
        cell.imageView.kf.setImage(with: URL(string: category.imageURLString))
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.alpha = 0.35
        cell.imageView.layer.masksToBounds = true
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = 10

        cell.titleLabel.text = category.title.uppercased()
        cell.titleLabel.textColor = .white
        cell.titleLabel.font = uiConfig.boldFont(size: 12)
        cell.titleLabel.alpha = 0.9
        cell.titleLabel.backgroundColor = .clear

        if let colorString = category.colorString {
            cell.containerView.backgroundColor = UIColor(hexString: colorString)
        } else {
            cell.containerView.backgroundColor = UIColor(hexString: "#000000")
        }
        cell.containerView.layer.cornerRadius = 10
        cell.clipsToBounds = true
    }

    func cellClass() -> UICollectionViewCell.Type {
        return TopCategoryCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: 150, height: 75)
    }
}
