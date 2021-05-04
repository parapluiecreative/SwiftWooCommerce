//
//  ATCFormImageRowAdapter.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCFormImageRowAdapter: ATCGenericCollectionRowAdapter {
    let size: CGSize
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(size: CGSize, uiConfig: ATCUIGenericConfigurationProtocol) {
        self.size = size
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let viewModel = object as? ATCFormImageViewModel, let cell = cell as? ATCImageCollectionViewCell {
            if let image = viewModel.image {
                cell.atcImageView.image = image
                cell.atcImageView.contentMode = .scaleAspectFill
            } else {
                cell.atcImageView.image = UIImage.localImage("camera-filled-icon-large", template: true)
                cell.atcImageView.backgroundColor = uiConfig.mainThemeForegroundColor
                cell.atcImageView.tintColor = uiConfig.mainThemeBackgroundColor
                cell.atcImageView.contentMode = .center
            }
            if viewModel.isVideoPreview {
                cell.atcVideoPreviewIcon.isHidden = false
            } else {
                cell.atcVideoPreviewIcon.isHidden = true
            }
            cell.atcImageView.layer.cornerRadius = 8.0
            cell.atcImageView.layer.masksToBounds = true
            cell.atcImageView.clipsToBounds = true
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCImageCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return size
    }
}
