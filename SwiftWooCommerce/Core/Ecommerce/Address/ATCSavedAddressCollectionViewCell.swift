//
//  ATCSavedAddressCollectionViewCell.swift
//  Shopertino
//
//  Created by Mayil Kannan on 15/09/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

protocol ATCSavedAddressCollectionViewCellDelegate: class {
    func cell(_ cell: ATCSavedAddressCollectionViewCell, address: ATCAddress, status: String)
}

class ATCSavedAddressCollectionViewCell: UICollectionViewCell {
    weak var delegate: ATCSavedAddressCollectionViewCellDelegate?
    var viewModel: ATCAddress? = nil

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    func configure(viewModel: ATCAddress) {
        self.viewModel = viewModel
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
    }

    @objc func didTapEditButton() {
        if let address = viewModel {
            self.delegate?.cell(self, address: address, status: "Edit")
        }
    }
    
    @objc func didTapDeleteButton() {
        if let address = viewModel {
            self.delegate?.cell(self, address: address, status: "Delete")
        }
    }
}
