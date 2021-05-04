//
//  ATCDateRangeAdapter.swift
//  DashboardApp
//
//  Created by Florian Marcu on 7/28/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCDateRangeAdapter: ATCGenericCollectionRowAdapter {

    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let dateRangeModel = object as? ATCDateRangeModel,
            let cell = cell as? ATCDateRangeCollectionViewCell {
            let caretImage = UIImage.localImage("caret-icon", template: true)
            cell.calendarImageView.image = caretImage
            cell.calendarImageView.tintColor = uiConfig.mainSubtextColor

            cell.dateRangeLabel.text = dateRangeModel.timePeriodText
            cell.dateRangeTitleLabel.text = dateRangeModel.titleText

            cell.dateRangeTitleLabel.font = uiConfig.boldLargeFont
            cell.dateRangeTitleLabel.textColor = uiConfig.mainTextColor

            cell.dateRangeLabel.font = uiConfig.regularMediumFont
            cell.dateRangeLabel.textColor = uiConfig.mainSubtextColor
            cell.setNeedsLayout()

            cell.hairlineView.backgroundColor = uiConfig.hairlineColor
            cell.hairlineViewTop.backgroundColor = uiConfig.hairlineColor
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCDateRangeCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let _ = object as? ATCDateRangeModel else { return .zero }
        return CGSize(width: containerBounds.width, height: 50)
    }
}
