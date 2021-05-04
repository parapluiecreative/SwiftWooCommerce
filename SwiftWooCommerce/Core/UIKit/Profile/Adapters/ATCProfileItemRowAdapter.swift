//
//  ATCProfileItemRowAdapter.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/2/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCProfileItemRowAdapter: ATCGenericCollectionRowAdapter {
    var uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCProfileItem, let cell = cell as? ATCProfileItemCollectionViewCell else { return }
        cell.iconImageView.image = viewModel.icon
        cell.iconImageView.tintColor = viewModel.color
        cell.iconImageView.contentMode = .scaleAspectFill

        cell.itemTitleLabel.text = viewModel.title
        cell.itemTitleLabel.font = uiConfig.regularFont(size: 16.0)

        switch viewModel.type {
        case .arrow:
            cell.accessoryImageView.image = UIImage.localImage("forward-arrow-black", template: true).localized
            cell.accessoryImageView.tintColor = UIColor(hexString: "#DBDBDE")
        default:
            cell.accessoryImageView.image = nil
        }

        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCProfileItemCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let _ = object as? ATCProfileItem else { return .zero }
        return CGSize(width: containerBounds.width, height: 50.0)
    }
}
