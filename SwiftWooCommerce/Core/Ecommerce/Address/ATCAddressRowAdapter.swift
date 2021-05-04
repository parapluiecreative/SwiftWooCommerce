//
//  ATCAddressRowAdapter.swift
//  Shopertino
//
//  Created by Mayil Kannan on 15/09/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ATCAddressRowAdapter: ATCGenericCollectionRowAdapter {
    weak var parentVC: ATCGenericCollectionViewController?
    weak var delegate: ATCSavedAddressCollectionViewCellDelegate?
    let uiConfig: ATCUIGenericConfigurationProtocol
    var viewer: ATCUser?
    let dsProvider: ATCEcommerceDataSourceProvider?
    init(parentVC: ATCGenericCollectionViewController,
         uiConfig: ATCUIGenericConfigurationProtocol,
         viewer: ATCUser?,
         dsProvider: ATCEcommerceDataSourceProvider?) {
        self.parentVC = parentVC
        self.uiConfig = uiConfig
        self.viewer = viewer
        self.dsProvider = dsProvider
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let address = object as? ATCAddress, let cell = cell as? ATCSavedAddressCollectionViewCell else { return }
        cell.delegate = self
        cell.configure(viewModel: address)
        cell.nameLabel.text = address.name
        cell.nameLabel.font = uiConfig.regularFont(size: 18)
        cell.nameLabel.textColor = uiConfig.mainTextColor
              
        cell.addressLabel.text = address.line1
        cell.addressLabel.font = uiConfig.regularFont(size: 14)
        cell.addressLabel.textColor = uiConfig.mainSubtextColor

        cell.phoneNumberLabel.text = address.phone
        cell.phoneNumberLabel.font = uiConfig.regularFont(size: 14)
        cell.phoneNumberLabel.textColor = uiConfig.mainSubtextColor
        
        cell.editButton.backgroundColor = uiConfig.mainThemeForegroundColor
        cell.editButton.setTitleColor(uiConfig.mainThemeBackgroundColor, for: .normal)
        cell.editButton.layer.cornerRadius = 3
        cell.editButton.titleLabel?.font = uiConfig.regularFont(size: 14)

        cell.deleteButton.setTitleColor(uiConfig.mainThemeForegroundColor, for: .normal)
        cell.deleteButton.layer.cornerRadius = 3
        cell.deleteButton.configure(color: uiConfig.mainThemeForegroundColor, font: uiConfig.regularFont(size: 14))

        
        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cell.containerView.layer.cornerRadius = 10
        cell.containerView.clipsToBounds = true
        cell.backgroundColor = .clear
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCSavedAddressCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width,
                      height: 160)
    }
}

extension ATCAddressRowAdapter: ATCSavedAddressCollectionViewCellDelegate {
    func cell(_ cell: ATCSavedAddressCollectionViewCell, address: ATCAddress, status: String) {
        switch status {
        case "Edit":
            let createAddressVC = ATCCreateAddressViewController(user: viewer,
                                                                 dsProvider: dsProvider)
            createAddressVC.address = address
            createAddressVC.delegate = self
            let navController = UINavigationController(rootViewController: createAddressVC)
            (parentVC as? ATCSavedAddressViewController)?.present(navController, animated: true, completion: nil)
        case "Delete":
            if let userID = viewer?.uid {
                if let addressID = address.addressID {
                    Firestore.firestore().collection("users").document(userID).updateData(
                        ["shippingAddress.\(addressID)" : FieldValue.delete()
                        ]
                    ) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                            let alert = UIAlertController(title: "Error",
                                                          message: err.localizedDescription,
                                                          preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.parentVC?.present(alert, animated: true)
                        } else {
                            print("Successfully updated")
                            self.parentVC?.genericDataSource?.loadFirst()
                        }
                    }
                }
            }
        default: break
        }
    }
}

extension ATCAddressRowAdapter: ATCCreateAddressViewControllerDelegate {
    func createAddressVCDidUpdateAddress() {
        parentVC?.genericDataSource?.loadFirst()
    }
}
