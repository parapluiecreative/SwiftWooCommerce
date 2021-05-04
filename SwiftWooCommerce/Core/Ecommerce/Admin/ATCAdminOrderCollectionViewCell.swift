//
//  ATCAdminOrderCollectionViewCell.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/27/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import UIKit

protocol ATCAdminOrderCollectionViewCellDelegate: class {
    func cell(_ cell: ATCAdminOrderCollectionViewCell, didTapChangeStatusOrder order: ATCOrder)
}

class ATCAdminOrderCollectionViewCell: UICollectionViewCell {
    weak var delegate: ATCAdminOrderCollectionViewCellDelegate?
    var viewModel: ATCOrder? = nil

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var collectionContainerView: UIView!

    func configure(viewModel: ATCOrder) {
        self.viewModel = viewModel
        statusButton.addTarget(self, action: #selector(didTapStatusButton), for: .touchUpInside)
    }

    @objc func didTapStatusButton() {
        if let order = viewModel {
            self.delegate?.cell(self, didTapChangeStatusOrder: order)
        }
    }
}
