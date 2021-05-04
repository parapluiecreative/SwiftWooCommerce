//
//  ShopertinoHostViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ShopertinoHostViewController: UIViewController, UITabBarControllerDelegate {

    static var cartManager = ATCShoppingCartManager(cart: ATCShoppingCart())
    static var user: ATCUser? = nil

    let uiConfig: ShopertinoUIConfiguration
    let homeVC: HomeViewController
    let categoriesVC: UIViewController
    let profileVC: ProfileViewController
    let dsProvider: ATCEcommerceDataSourceProvider
    let searchVC: SearchViewController
    let ordersVC: OrderViewController
    let profileManager: ATCFirebaseProfileManager?
    var user: ATCUser?
    let serverConfig: ATCOnboardingServerConfigurationProtocol

    var badgeButton = { () -> ATCBadgedButton in
        let button = ATCBadgedButton()
        button.setImage(UIImage.localImage("shopping-bag-filled", template: true), for: .normal)
        button.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        button.addTarget(self, action: #selector(didTapShoppingCartButton), for: .touchUpInside)
        button.count = ShopertinoHostViewController.cartManager.productCount()
        button.snp.makeConstraints({ (maker) in
            maker.width.equalTo(25)
            maker.height.equalTo(25)
        })
        return button
    }()

    let cartViewController: ShoppingCartViewController
    let ecommerceConfiguration: ATCEcommerceConfiguration

    lazy var hostController: ATCHostViewController = { [unowned self] in
        let menuItems: [ATCNavigationItem] = [
            ATCNavigationItem(title: "HOME".localizedInApp,
                              viewController: homeVC,
                              image: UIImage.localImage("home-shop-icon", template: true),
                              type: .viewController),
            ATCNavigationItem(title: "SHOP".localizedInApp,
                              viewController: categoriesVC,
                              image: UIImage.localImage("four-square-grid-icon", template: true),
                              type: .viewController),
            ATCNavigationItem(title: "BAG".localizedInApp,
                              viewController: cartViewController,
                              image: UIImage.localImage("shopping-bag", template: true),
                              type: .viewController),
            ATCNavigationItem(title: "SEARCH".localizedInApp,
                              viewController: searchVC,
                              image: UIImage.localImage("search-icon", template: true),
                              type: .viewController),
            ATCNavigationItem(title: "ORDERS".localizedInApp,
                              viewController: ordersVC,
                              image: UIImage.localImage("delivery-icon", template: true),
                              type: .viewController),
            ATCNavigationItem(title: "WISHLIST".localizedInApp,
                              viewController: WishlistViewController(uiConfig: uiConfig, dsProvider: self.dsProvider),
                              image: UIImage.localImage("heart-icon", template: true),
                              type: .viewController),
            ATCNavigationItem(title: "PROFILE".localizedInApp,
                              viewController: profileVC,
                              image: UIImage.localImage("profile-icon", template: true),
                              type: .viewController),
            ATCNavigationItem(title: "LOGOUT".localizedInApp,
                              viewController: UIViewController(),
                              image: UIImage.localImage("logout-menu-item", template: true),
                              type: .logout)
        ]
        let menuConfiguration = ATCMenuConfiguration(user: nil,
                                                     cellClass: MenuItemCollectionViewCell.self,
                                                     headerHeight: 0,
                                                     items: menuItems,
                                                     uiConfig: ATCMenuUIConfiguration())

        let config = ATCHostConfiguration(menuConfiguration: menuConfiguration,
                                          style: .sideBar,
                                          topNavigationRightViews: [self.badgeButton],
                                          titleView: nil,
                                          topNavigationLeftImage: UIImage.localImage("menu-icon", template: true), // UIImage.localImage("menu-hamburger-rounded-icon", template: true),
                                          topNavigationTintColor: nil,
                                          statusBarStyle: .default,
                                          uiConfig: uiConfig,
                                          pushNotificationsEnabled: true,
                                          locationUpdatesEnabled: false)
        let hostVC = ATCHostViewController(configuration: config,
                                           onboardingCoordinator: dsProvider.onboardingCoordinator(uiConfig: uiConfig),
                                           walkthroughVC: dsProvider.walkthroughVC(uiConfig: uiConfig))
        hostVC.delegate = self
        return hostVC
        }()

    init(configuration: ATCEcommerceConfiguration,
         uiConfig: ShopertinoUIConfiguration,
         loginManager: ATCFirebaseLoginManager?,
         dsProvider: ShopertinoDataSourceProvider,
         profileManager: ATCFirebaseProfileManager? = nil,
         serverConfig: ShopertinoServerConfig) {
        self.ecommerceConfiguration = configuration
        self.serverConfig = serverConfig
        self.dsProvider = dsProvider
        self.uiConfig = uiConfig
        self.profileManager = profileManager
        self.homeVC = HomeViewController(uiConfig: uiConfig, dsProvider: dsProvider)
        self.cartViewController = ShoppingCartViewController(
            cartManager: ShopertinoHostViewController.cartManager,
            placeOrderManager: dsProvider.placeOrderManager,
            uiConfig: uiConfig,
            dsProvider: dsProvider
        )
        self.profileVC = ProfileViewController(uiConfig: uiConfig,
                                               cartVC: cartViewController,
                                               loginManager: loginManager,
                                               dsProvider: dsProvider,
                                               manager: profileManager)
        self.categoriesVC = CategoriesViewController(
            dsProvider: dsProvider,
            uiConfig: uiConfig
        )
        self.ordersVC = OrderViewController(uiConfig: uiConfig,
                                            cartVC: cartViewController,
                                            dsProvider: dsProvider)
        self.searchVC = SearchViewController(uiConfig: uiConfig, dsProvider: dsProvider)
//        self.ordersVC = ATCOrderViewController(uiConfig: uiConfig,
//                                               cartVC: cartViewController,
//                                               dsProvider: dsProvider)
//        self.reservationVC = ATCReservationViewControllerFactory().reservationVC(shop: MockStore.shop, serverConfig: serverConfig)

        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateCart), name: kATCNotificationDidAddProductToCart, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewControllerWithView(hostController)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    @objc
    private func didTapShoppingCartButton() {
        if (self.hostController.navigationRootController?.topViewController != cartViewController) {
            self.hostController.navigationRootController?.pushViewController(cartViewController, animated: true)
        }
    }

    @objc
    private func didUpdateCart() {
        self.badgeButton.count = ShopertinoHostViewController.cartManager.productCount()
        self.cartViewController.update()
    }
}

extension ShopertinoHostViewController: ATCHostViewControllerDelegate {
    func hostViewController(_ hostViewController: ATCHostViewController, didLogin user: ATCUser) {
        ShopertinoHostViewController.cartManager = ATCShoppingCartManager(cart: ATCShoppingCartHelper.persistedCartOrEmpty(with: user.uid ?? ""))
        ShopertinoHostViewController.cartManager.cart.vendorID = user.uid
        ShopertinoHostViewController.user = user
        self.user = user
        self.profileVC.user = user
        self.ordersVC.user = user
        self.cartViewController.user = user
    }

    func hostViewController(_ hostViewController: ATCHostViewController, didSync user: ATCUser) {
        ShopertinoHostViewController.cartManager = ATCShoppingCartManager(cart: ATCShoppingCartHelper.persistedCartOrEmpty(with: user.uid ?? ""))
        ShopertinoHostViewController.cartManager.cart.vendorID = user.uid
        badgeButton.count = ShopertinoHostViewController.cartManager.productCount()
        ShopertinoHostViewController.user = user
        self.user = user
        self.ordersVC.user = user
        self.cartViewController.user = user
        self.profileVC.user = user
        NotificationCenter.default.post(name: kATCNotificationDidUpdateCartManager, object: nil)
    }
}
