//
//  ReservationViewController.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/21/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ReservationViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var reserveButton: UIButton!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var detailsTextField: UITextField!

    let shop: ATCShop
    let serverConfig: ATCOnboardingServerConfigurationProtocol
    let uiConfig: ATCUIGenericConfigurationProtocol
    
    init(shop: ATCShop,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        self.shop = shop
        self.serverConfig = serverConfig
        self.uiConfig = uiConfig
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "Reservations".localizedEcommerce
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = UIColor.white.darkModed
    }

    private func configureUI() {
        headerImageView.kf.setImage(with: URL(string: shop.imageURLString))

        nameLabel.text = shop.name
        nameLabel.font = uiConfig.regularLargeFont

        descriptionLabel.text = shop.streetAddress
        descriptionLabel.textColor = uiConfig.mainSubtextColor
        descriptionLabel.font = uiConfig.regularSmallFont

        firstNameTextField.placeholder = "First Name".localizedEcommerce
        lastNameTextField.placeholder = "Last Name".localizedEcommerce
        phoneTextField.placeholder = "Phone Number".localizedEcommerce
        detailsTextField.placeholder = "Reservation Details".localizedEcommerce

        reserveButton.backgroundColor = uiConfig.mainThemeForegroundColor
        reserveButton.setTitleColor(.white, for: .normal)
        reserveButton.layer.cornerRadius = 5
        reserveButton.titleLabel?.font = uiConfig.boldFont(size: 16)
        reserveButton.addTarget(self, action: #selector(didTapReserveButton), for: .touchUpInside)
        reserveButton.setTitle("Make Reservation".localizedEcommerce, for: .normal)
    }

    @objc func didTapReserveButton() {
        if (serverConfig.isFirebaseAuthEnabled) {
            let firebaseWriter = ATCFirebaseFirestoreWriter(tableName: "restaurant_reservations")
            guard let firstName = firstNameTextField.text,
                let lastName = lastNameTextField.text,
                let phoneNumber = phoneTextField.text else {
                    let alert = UIAlertController(title: "Couldn't make the reservation".localizedEcommerce, message: "Please fill out the mandatory fields (phone, first and last name).".localizedEcommerce, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
            }

            if firstName.count == 0 || lastName.count == 0 || phoneNumber.count == 0 {
                let alert = UIAlertController(title: "Couldn't make the reservation".localizedEcommerce, message: "Please fill out the mandatory fields (phone, first and last name).".localizedEcommerce, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }

            let representation: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "phoneNumber": phoneNumber,
                "details": detailsTextField.text ?? ""
            ]
            firebaseWriter.save(representation) {
                let alert = UIAlertController(title: "We received your reservation. See you there!".localizedEcommerce, message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .cancel, handler: nil))
                self.present(alert, animated: true)
                self.firstNameTextField.text = nil
                self.lastNameTextField.text = nil
                self.phoneTextField.text = nil
                self.detailsTextField.text = nil
            }
        }
    }
}
