//
//  CartViewController.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 8/29/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import PassKit
import Stripe
import UIKit

class ATCShoppingCartViewController: ATCCollectionViewController, UICollectionViewDelegateFlowLayout, ATCShoppingCartManagerDelegate, PKPaymentAuthorizationViewControllerDelegate {

    let cartManager: ATCShoppingCartManager
    fileprivate let kCellReuseIdentifier = "CartItemCollectionViewCell"
    fileprivate let checkoutButton = UIButton()
    fileprivate let config: ATCEcommerceConfiguration
    
    var user: ATCUser?
    let serverConfig: ATCOnboardingServerConfigurationProtocol
    let uiConfig: ATCUIGenericConfigurationProtocol
    let placeOrderManager: ATCPlaceOrderManagerProtocol?
    let uiEcommerceConfig: ATCUIConfigurationProtocol
    var dsProvider: ATCEcommerceDataSourceProvider?

    init(cartManager: ATCShoppingCartManager,
         uiConfig: ATCUIGenericConfigurationProtocol,
         config: ATCEcommerceConfiguration,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         placeOrderManager: ATCPlaceOrderManagerProtocol?,
         uiEcommerceConfig: ATCUIConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider?) {
        self.cartManager = cartManager
        self.config = config
        self.uiConfig = uiConfig
        self.serverConfig = serverConfig
        self.placeOrderManager = placeOrderManager
        self.uiEcommerceConfig = uiEcommerceConfig
        self.dsProvider = dsProvider

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        super.init(collectionViewLayout: layout)
        self.title = self.uiEcommerceConfig.cartScreenTitle
//        tabBarItem = UITabBarItem(title: uiEcommerceConfig.cartTabBarItemTitle, image: uiEcommerceConfig.cartTabBarItemImage, selectedImage: uiEcommerceConfig.cartTabBarItemSelectedImage).tabBarWithNoTitle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = uiConfig.mainThemeBackgroundColor
        collectionView?.register(UINib(nibName: kCellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: kCellReuseIdentifier)
        collectionView?.register(UINib(nibName: "CartFooterCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "CartFooterCollectionReusableView")

        checkoutButton.backgroundColor = uiEcommerceConfig.cartScreenCheckoutButtonBackgroundColor
        checkoutButton.setTitleColor(uiEcommerceConfig.cartScreenCheckoutButtonTextColor, for: .normal)
        checkoutButton.layer.cornerRadius = 0
        checkoutButton.titleLabel?.font = uiEcommerceConfig.cartScreenCheckoutButtonFont
        checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        checkoutButton.setTitle(uiEcommerceConfig.cartScreenCheckoutButtonTitle, for: .normal)
        collectionView?.addSubview(checkoutButton)
        collectionView?.bringSubviewToFront(checkoutButton)

        checkoutButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            maker.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            maker.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            maker.height.equalTo(uiEcommerceConfig.cartScreenCheckoutButtonHeight)
        }
        self.update()
    }

    func update() {
        let isEnabled = (cartManager.totalPrice() > 0)
        checkoutButton.isEnabled = isEnabled
        checkoutButton.alpha = (isEnabled ? 1 : 0.7)
        self.collectionView?.reloadData()
    }

    @objc fileprivate func didTapCheckoutButton() {
        if cartManager.totalPrice() > 0 {
            // Write Order to Firebase
            if let placeOrderManager = placeOrderManager,
                serverConfig.isFirebaseAuthEnabled,
                !config.stripeEnabled,
                !config.applePayEnabled {
                // If payments are not enabled, just simply place the order without any payment or address
                placeOrderManager.placeOrder(user: user,
                                             address: ATCAddress(line1: "No address".localizedEcommerce),
                                             cart: cartManager.cart) {[weak self] (success) in
                                                guard let `self` = self else { return }
                                                let placingOrderVC = ATCPlacingOrderViewController(nibName: "ATCPlacingOrderViewController",
                                                                                                   bundle: nil,
                                                                                                   uiConfig: self.uiConfig,
                                                                                                   cartManager: self.cartManager,
                                                                                                   address: ATCAddress(line1: "No address".localizedEcommerce))
                                                placingOrderVC.delegate = self
                                                self.present(placingOrderVC, animated: true) {
                                                    self.cartManager.clearProducts()
                                                    self.update()
                                                }
                }
            }
            // Continue to Check out / Payment flow
            if (config.stripeEnabled) {
                // Stripe
                let stripeSettings = Settings(theme: ATCStripeThemeFactory().stripeTheme(for: self.uiConfig),
                                              applePayEnabled: true,
                                              requiredBillingAddressFields: .none,
                                              requiredShippingAddressFields: [.postalAddress],// [.emailAddress, .name, .postalAddress],
                                              shippingType: .delivery)
                let stripeVC = CheckoutViewController(uiConfig: uiConfig,
                                                      price: Int(cartManager.totalPrice() * 100),
                                                      products: cartManager.distinctProducts(),
                                                      settings: stripeSettings,
                                                      serverConfig: serverConfig,
                                                      dsProvider: dsProvider,
                                                      user: user)
                stripeVC.delegate = self
                self.navigationController?.pushViewController(stripeVC, animated: true)
            } else if config.applePayEnabled {
                // Apple Pay
                let payManager = ATCApplePayManager(items: cartManager.applePayItems())
                if let vc = payManager.paymentViewController() {
                    vc.delegate = self
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: - ATCShoppingCartManagerDelegate
    func cartManagerDidClearProducts(_ cartManager: ATCShoppingCartManager) {
        self.collectionView?.reloadData()
    }

    func cartManagerDidAddProduct(_ cartManager: ATCShoppingCartManager) {
        self.collectionView?.reloadData()
    }

    // MARK: - PKPaymentAuthorizationViewControllerDelegate
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        if let placeOrderManager = placeOrderManager {
            placeOrderManager.placeOrder(user: user,
                                         address: convertApplePayAddressToATCAddress(shippingContact: payment.shippingContact),
                                         cart: cartManager.cart) {[weak self] (success) in
                                            guard let `self` = self else { return }
                                            let placingOrderVC = ATCPlacingOrderViewController(nibName: "ATCPlacingOrderViewController",
                                                                                               bundle: nil,
                                                                                               uiConfig: self.uiConfig,
                                                                                               cartManager: self.cartManager,
                                                                                               address: self.convertApplePayAddressToATCAddress(shippingContact: payment.shippingContact))
                                            placingOrderVC.delegate = self
                                            self.present(placingOrderVC, animated: true) {
                                                self.cartManager.clearProducts()
                                                self.update()
                                            }
            }
        } else {
            cartManager.clearProducts()
            self.update()
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ATCShoppingCartViewController: CheckoutViewControllerDelegate {
    func checkoutViewController(_ vc: CheckoutViewController, didCompleteCheckout address: ATCAddress) {
        if let placeOrderManager = placeOrderManager {
            placeOrderManager.placeOrder(user: user, address: address, cart: cartManager.cart) {[weak self] (success) in
                guard let `self` = self else { return }
                let placingOrderVC = ATCPlacingOrderViewController(nibName: "ATCPlacingOrderViewController",
                                                                   bundle: nil,
                                                                   uiConfig: self.uiConfig,
                                                                   cartManager: self.cartManager,
                                                                   address: address)
                placingOrderVC.delegate = self
                self.present(placingOrderVC, animated: true) {
                    self.cartManager.clearProducts()
                    self.update()
                }
            }
        } else {
            cartManager.clearProducts()
            self.update()
        }
    }
}

extension ATCShoppingCartViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseIdentifier, for: indexPath) as? CartItemCollectionViewCell else {
            fatalError()
        }
        let item = cartManager.object(at: indexPath.row)
        cell.configure(item: item, uiConfig: uiConfig)
        return cell
    }

    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartManager.numberOfObjects()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: uiEcommerceConfig.cartScreenCellHeight)
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionFooter) {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CartFooterCollectionReusableView", for: indexPath)
            // Customize footerView here
            if let footerView = footerView as? CartFooterCollectionReusableView {
                footerView.configure(totalPrice: cartManager.totalPrice(), uiEcommerceConfig: uiEcommerceConfig)
            }
            return footerView
        } else if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CartHeaderCollectionReusableView", for: indexPath)
            // Customize headerView here
            return headerView
        }
        fatalError()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: uiEcommerceConfig.cartScreenFooterCellHeight)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = cartManager.object(at: indexPath.row)
        let editView = EditCartBottomDrawerView(shoppingItem: item, uiConfig: uiConfig)
        editView.delegate = self
        showBottomDrawer(with: editView, customViewHeight: 280)
    }
}

extension ATCShoppingCartViewController: EditCartBottomDrawerViewDelegate {
    func editCartViewDidTapRemoveButton(_ editView: EditCartBottomDrawerView) {
        self.cartManager.setProduct(product: editView.viewModel.product,
                                    vendorID: cartManager.cart.vendorID,
                                    vendor: cartManager.cart.vendor,
                                    quantity: 0)
        self.dismissBottomDrawerOverlay()
        self.update()
    }

    func editCartView(_ editView: EditCartBottomDrawerView, didTapUpdateWith quantity: Int) {
        let viewModel = editView.viewModel
        self.cartManager.setProduct(product: viewModel.product,
                                    vendorID: cartManager.cart.vendorID,
                                    vendor: cartManager.cart.vendor,
                                    quantity: quantity)
        self.dismissBottomDrawerOverlay()
        self.update()
    }
}

extension ATCShoppingCartViewController {
    func convertApplePayAddressToATCAddress(shippingContact: PKContact?) -> ATCAddress {
        guard let shippingContact = shippingContact else { return ATCAddress() }
        return ATCAddress(name: shippingContact.name?.description,
                          line1: shippingContact.postalAddress?.street,
                          line2: shippingContact.postalAddress?.subLocality,
                          city: shippingContact.postalAddress?.city,
                          state: shippingContact.postalAddress?.state,
                          postalCode: shippingContact.postalAddress?.postalCode,
                          country: shippingContact.postalAddress?.country,
                          phone: shippingContact.phoneNumber?.stringValue,
                          email: shippingContact.emailAddress)
    }
}

extension ATCShoppingCartViewController: PlacingOrderViewProtocol {
    func didFinishLoading() {
        self.navigationController?.popViewController(animated: true)
    }
}
