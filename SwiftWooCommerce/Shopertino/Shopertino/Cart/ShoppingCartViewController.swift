//
//  ShoppingCartViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/7/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Stripe
import UIKit
import SafariServices

class ShoppingCartViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var cartItemsView: UIView!
    @IBOutlet var cartFooterView: UIView!
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var totalTitleLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!

    var cartManager: ATCShoppingCartManager
    let uiConfig: ATCUIGenericConfigurationProtocol
    var imageVC: ProductImagesViewController?
    var cartItemsVC: ShoppingCartItemsViewController?
    let placeOrderManager: ATCPlaceOrderManagerProtocol?
    var user: ATCUser? = nil {
        didSet {
            self.cartManager = ShopertinoHostViewController.cartManager
            self.cartItemsVC?.cartManager = ShopertinoHostViewController.cartManager
        }
    }

    var hasBeenLoaded: Bool = false
    var dsProvider: ATCEcommerceDataSourceProvider?
    init(cartManager: ATCShoppingCartManager,
         placeOrderManager: ATCPlaceOrderManagerProtocol?,
         uiConfig: ATCUIGenericConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider?) {

        self.cartManager = cartManager
        self.placeOrderManager = placeOrderManager
        self.uiConfig = uiConfig
        self.dsProvider = dsProvider

        super.init(nibName: "ShoppingCartViewController", bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateCartManager), name: kATCNotificationDidUpdateCartManager, object: nil)
    }
    
    @objc
    func didUpdateCartManager() {
        prepareUIAfterViewDidLoad()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIAfterViewDidLoad()
    }
    
    private func prepareUIAfterViewDidLoad() {
        view.backgroundColor = UIColor.darkModeColor(hexString: "#fafafa")
        self.hasBeenLoaded = true
        cartItemsView.backgroundColor = UIColor.darkModeColor(hexString: "#fafafa")

        containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cartItemsView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cartFooterView.backgroundColor = uiConfig.mainThemeBackgroundColor
        
        cartItemsVC = ShoppingCartItemsViewController(cartManager: cartManager, uiConfig: uiConfig)
        cartItemsVC?.delegate = self
        guard let cartItemsVC = cartItemsVC else { return }
        cartItemsVC.view.frame = cartItemsView.bounds
        self.addChildViewControllerWithView(cartItemsVC, toView: cartItemsView)
        cartItemsVC.update()

        buyButton.configure(color: uiConfig.mainThemeBackgroundColor,
                            font: uiConfig.boldFont(size: 16),
                            cornerRadius: 5,
                            borderColor: nil,
                            backgroundColor: uiConfig.mainThemeForegroundColor.darkModed)
        buyButton.setTitle("CONTINUE".localizedInApp, for: .normal)
        buyButton.addTarget(self, action: #selector(didTapBuyButton), for: .touchUpInside)

        totalTitleLabel.text = "Total".localizedInApp
        totalTitleLabel.textColor = uiConfig.mainThemeForegroundColor.darkModed
        totalTitleLabel.font = uiConfig.regularFont(size: 16)

        totalLabel.text = "$" + cartManager.totalPrice().twoDecimalsString()
        totalLabel.textColor = uiConfig.mainThemeForegroundColor.darkModed
        totalLabel.font = uiConfig.boldFont(size: 18)

        cartFooterView.dropShadow()

        self.updateUI()

        self.title = "Shopping Bag".localizedInApp
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }

    @objc private func didTapBuyButton() {
        let serverConfig = ShopertinoServerConfig()
        if (serverConfig.isStripeEnabled) {
            let stripeSettings = Settings(theme: ATCStripeThemeFactory().stripeTheme(for: uiConfig),
                                          applePayEnabled: true,
                                          requiredBillingAddressFields: .none,
                                          requiredShippingAddressFields: [.postalAddress], // [.emailAddress, .name, .postalAddress], // [.phoneNumber]
                shippingType: .delivery)

            let stripeVC = CheckoutViewController(cartManager: cartManager,
                                                  uiConfig: uiConfig,
                                                  price: Int(cartManager.totalPrice() * 100),
                                                  products: cartManager.distinctProducts(),
                                                  settings: stripeSettings,
                                                  serverConfig: serverConfig,
                                                  dsProvider: dsProvider,
                                                  user: user)
            stripeVC.delegate = self
            self.navigationController?.pushViewController(stripeVC, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func update() {
        cartItemsVC?.update()
        self.updateUI()
    }

    private func updateUI() {
        guard hasBeenLoaded else { return }

        let isEnabled = (cartManager.totalPrice() > 0)
        buyButton.isEnabled = isEnabled
        buyButton.alpha = (isEnabled ? 1 : 0.7)

        totalLabel.text = "$" + cartManager.totalPrice().twoDecimalsString()
    }
}

extension ShoppingCartViewController: ShoppingCartItemsViewControllerDelegate {
    func itemsViewControllerDidUpdateQuantities(_ vc: ShoppingCartItemsViewController) {
        self.updateUI()
    }
}

extension ShoppingCartViewController: CheckoutViewControllerDelegate {
    func checkoutViewController(_ vc: CheckoutViewController, didCompleteCheckout address: ATCAddress) {
        if let placeOrderManager = placeOrderManager {
            let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
            hud.show(in: self.view)
            placeOrderManager.placeOrder(user: user, address: address, cart: cartManager.cart) {[weak self] (success) in
                guard let `self` = self else { return }
                hud.dismiss()
                if let webUrl = self.cartManager.cart.webUrl {

                } else {
                    self.cartManager.clearProducts()
                    self.update()
                    let alertController = UIAlertController(title: "Success", message: "Your purchase was successful!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            cartManager.clearProducts()
            self.update()
        }
    }
}
