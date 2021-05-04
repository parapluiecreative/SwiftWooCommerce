//
//  ProfileViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/18/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ProfileViewController: ATCProfileViewController {
    let manager: ATCFirebaseProfileManager?
    let loginManager: ATCFirebaseLoginManager?

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         cartVC: ShoppingCartViewController,
         loginManager: ATCFirebaseLoginManager?,
         dsProvider: ATCEcommerceDataSourceProvider,
         manager: ATCFirebaseProfileManager?) {
        self.manager = manager
        self.loginManager = loginManager

        super.init(items: ProfileViewController.selfProfileItems(),
                   uiConfig: uiConfig)

        self.selectionBlock = {[weak self] (nav, model, index) in
            guard let `self` = self else { return }
            if let _ = model as? ATCProfileButtonItem {
                // Logout
                NotificationCenter.default.post(name: kLogoutNotificationName, object: nil)
            } else if let item = model as? ATCProfileItem {
                if item.title == "Settings".localizedInApp {
                    let settingsVC = ProfileSettingsViewController()
                    self.navigationController?.pushViewController(settingsVC, animated: true)
                } else if item.title == "Account Details" {
                    if let user = self.user {
                        let accountSettingsVC = ATCAccountDetailsViewController(user: user,
                                                                                manager: manager,
                                                                                cancelEnabled: true)
                        accountSettingsVC.delegate = self
                        let navController = UINavigationController(rootViewController: accountSettingsVC)
                        nav?.present(navController, animated: true, completion: nil)
                    }
                } else if item.title == "Contact Us".localizedInApp {
                    let contactVC = ATCSettingsContactUsViewController()
                    self.navigationController?.pushViewController(contactVC, animated: true)
                } else if item.title == "Wishlist".localizedInApp {
                    let wishlistVC = WishlistViewController(uiConfig: uiConfig, dsProvider: dsProvider)
                    self.navigationController?.pushViewController(wishlistVC, animated: true)
                } else if item.title == "Order History".localizedInApp {
                    let ordersVC = OrderViewController(uiConfig: uiConfig,
                                                       cartVC: cartVC,
                                                       dsProvider: dsProvider)
                    ordersVC.user = self.user
                    self.navigationController?.pushViewController(ordersVC, animated: true)
                } else if item.title == "My Products".localizedInApp {
                    let authoredProductsVC = ATCAuthoredProductsViewController(uiConfig: uiConfig,
                                                                    dsProvider: dsProvider)
                    authoredProductsVC.user = self.user
                    self.navigationController?.pushViewController(authoredProductsVC, animated: true)
                } else if item.title == "Shipping Addresses" {
                    if let user = self.user {
                        let savedAddressVC = ATCSavedAddressViewController(uiConfig: uiConfig,
                                                                        dsProvider: dsProvider,
                                                                        viewer: user)
                        let navController = UINavigationController(rootViewController: savedAddressVC)
                        nav?.present(navController, animated: true, completion: nil)
                    }
                }
            }
        }
        self.title = "Profile".localizedInApp
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate static func selfProfileItems() -> [ATCGenericBaseModel] {
        var items: [ATCGenericBaseModel] = []
        // Add the remaining items, such as Account Details, Settings and Contact Us
        items.append(contentsOf: [ATCProfileItem(icon: UIImage.localImage("list-icon", template: true),
                                                 title: "My Products".localizedInApp,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#6979F8")),
                                  ATCProfileItem(icon: UIImage.localImage("account-male-icon", template: true),
                                                 title: "Account Details".localizedInApp,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#6979F8")),
                                  ATCProfileItem(icon: UIImage.localImage("heart-filled-icon", template: true),
                                                 title: "Wishlist".localizedInApp,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#fb898e")),
                                  ATCProfileItem(icon: UIImage.localImage("delivery-icon", template: true),
                                                 title: "Order History".localizedInApp,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#ac73ff")),
                                  ATCProfileItem(icon: UIImage.localImage("map-marker-icon", template: true),
                                                 title: "Shipping Addresses".localizedInApp,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#ac73ff")),
                                  ATCProfileItem(icon: UIImage.localImage("settings-menu-item", template: true),
                                                 title: "Settings".localizedInApp,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#3F3356")),
                                  ATCProfileItem(icon: UIImage.localImage("contact-call-icon", template: true),
                                                 title: "Contact Us".localizedInApp,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#64E790"))
            ]);
        return items
    }
}

extension ProfileViewController: ATCAccountDetailsViewControllerDelegate {
    func accountDetailsVCDidUpdateProfile() -> Void {
        // Gets the new persistent user with updated profile and updates the view controller
        if let user = self.user {
            loginManager?.resyncPersistentUser(user: user) { (newUser, error) in
                guard let newUser = newUser else { return }
                self.user = newUser
            }
        }
    }
    
    func accountDetailsVCUpdateProfile(updatedUser: ATCUser) {
        self.user = updatedUser
    }
}
