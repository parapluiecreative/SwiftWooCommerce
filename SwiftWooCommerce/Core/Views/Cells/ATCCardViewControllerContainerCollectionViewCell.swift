//
//  ATCCardViewControllerContainerCollectionViewCell.swift
//  FinanceApp
//
//  Created by Florian Marcu on 3/16/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCCardViewControllerContainerCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!

    func configure(viewModel: ATCViewControllerContainerViewModel) {
        containerView.dropShadow()
        containerView.layer.cornerRadius = 15
        containerView.clipsToBounds = true
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        self.backgroundColor = .clear

        let viewController = viewModel.viewController

        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        self.setNeedsLayout()
        viewModel.parentViewController?.addChild(viewModel.viewController)
    }
}
