//
//  InstaMultiRowPageCarouselRowAdapter.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/26/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class InstaMultiRowPageCarouselRowAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? InstaMultiRowPageCarouselViewModel, let cell = cell as? InstaMultiRowPageCarouselCollectionViewCell else { return }
        cell.carouselContainerView.setNeedsLayout()
        cell.carouselContainerView.layoutIfNeeded()

        let viewController = viewModel.viewController

        if let dS = viewController.genericDataSource {
            let cnt = (dS.numberOfObjects() / 6) + (dS.numberOfObjects() % 6 > 0 ? 1 : 0)
            if (cnt > 1) {
                cell.pageControl.numberOfPages = cnt
                cell.pageControl.isHidden = false
            } else {
                cell.pageControl.isHidden = true
            }
            cell.pageControl.pageIndicatorTintColor = UIColor(hexString: "#e6e7e9")
            cell.pageControl.backgroundColor = .clear
            cell.pageControl.currentPageIndicatorTintColor = uiConfig.mainThemeForegroundColor
        }
        viewController.scrollDelegate = cell

        viewController.view.frame = cell.carouselContainerView.bounds
        cell.carouselContainerView.addSubview(viewController.view)
        cell.setNeedsLayout()
        viewModel.parentViewController?.addChild(viewModel.viewController)
        cell.carouselTitleLabel.text = viewModel.title
        cell.carouselTitleLabel.textColor = uiConfig.mainTextColor
        cell.carouselTitleLabel.font = uiConfig.boldFont(size: 18.0)
        cell.carouselContainerView.backgroundColor = .clear
        cell.containerView.backgroundColor = .clear
        cell.backgroundColor = .clear
    }

    func cellClass() -> UICollectionViewCell.Type {
        return InstaMultiRowPageCarouselCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? InstaMultiRowPageCarouselViewModel else { return .zero }
        return CGSize(width: containerBounds.width, height: viewModel.cellHeight)
    }
}
