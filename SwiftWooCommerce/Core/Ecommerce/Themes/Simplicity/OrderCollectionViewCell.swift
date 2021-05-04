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
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet var collectionContainerView: UIView!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var placeOrderButton: UIButton!
    @IBOutlet weak var containerView: UIView!

    private var viewModel: ATCOrder?
    weak var delegate: OrderCollectionViewCellDelegate?

    func configure(viewModel: ATCOrder) {
        self.viewModel = viewModel
        collectionContainerView.isUserInteractionEnabled = false
        placeOrderButton.addTarget(self, action: #selector(didTapAddToCartButton), for: .touchUpInside)
    }

    @objc func didTapAddToCartButton() {
        if let order = viewModel {
            self.delegate?.cell(self, didTapReorderOrder: order)
        }
    }
}
