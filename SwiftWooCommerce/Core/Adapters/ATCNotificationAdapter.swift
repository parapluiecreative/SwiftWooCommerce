//
//  ATCNotificationAdapter.swift
//  DashboardApp
//
//  Created by Florian Marcu on 7/28/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCNotificationAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCNotification, let cell = cell as? ATCNotificationCollectionViewCell else { return }
        cell.hairlineView.backgroundColor = uiConfig.hairlineColor
        cell.notificationContainerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        
        cell.categoryLabel.text = viewModel.category
        cell.categoryLabel.textColor = UIColor(hexString: "#BCC8CE").darkModed
        cell.categoryLabel.font = uiConfig.regularSmallFont

        cell.contentLabel.text = viewModel.content
        cell.contentLabel.textColor = UIColor(hexString: "#96999B").darkModed
        cell.contentLabel.font = uiConfig.regularMediumFont

        cell.timeLabel.text = viewModel.createdAt.timeAgoDisplay()
        cell.timeLabel.textColor = UIColor(hexString: "#BCC8CE").darkModed
        cell.timeLabel.font = uiConfig.italicMediumFont

        cell.badgeView.isHidden = !viewModel.isNotSeen
        cell.badgeView.backgroundColor = UIColor(hexString: "#F4771E").darkModed
        cell.badgeView.clipsToBounds = true
        cell.badgeView.layer.cornerRadius = 5

        cell.notificationImageView.tintColor = UIColor(hexString: "#96999B").darkModed
        cell.notificationImageView.image = UIImage.localImage(viewModel.icon, template: true)

        cell.setNeedsLayout()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCNotificationCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCNotification else { return .zero }
        return CGSize(width: containerBounds.width, height: 100)
    }
}
