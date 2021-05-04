//
//  OrderCollectionViewCell.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

protocol OrderCollectionViewCellDelegate:class {
    func cell(_ cell: OrderCollectionViewCell, didTapReorderOrder order: ATCOrder)
}
class OrderCollectionViewCell: UICollectionViewCell {
    @IBOutlet var orderImageView: UIImageView!
    @IBOutlet var collectionContainerView: UIView!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var placeOrderButton: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var headerBackgroundView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var footerBackgroundView: UIView!
    
    private var viewModel: ATCOrder?
    weak var delegate: OrderCollectionViewCellDelegate?

    func configure(viewModel: ATCOrder) {
        self.viewModel = viewModel
        placeOrderButton.addTarget(self, action: #selector(didTapAddToCartButton), for: .touchUpInside)
    }

    @objc func didTapAddToCartButton() {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
        if let order = viewModel {
            self.delegate?.cell(self, didTapReorderOrder: order)
        }
    }
}
