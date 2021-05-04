//
//  HostViewController.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 8/29/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCShoppingHostViewController: UIViewController, UITabBarControllerDelegate {

    let uiConfig: UIConfiguration
    let homeVC: ATCHomeCollectionViewController
    let categoriesVC: UIViewController
    let dsProvider: ATCEcommerceDataSourceProvider
    let searchVC: ATCGenericSearchViewController<Product>
    let ordersVC: ATCOrderViewController
    let reservationVC: ReservationViewController
    let profileVC: MyProfileViewController
    var adminOrdersVC: ATCAdminOrdersViewController? = nil
    var user: ATCUser? {
        didSet {
            hostController.configureMenuItems(self.menuItems(user: user)) // Update the drawer/tabbar menu
        }
    }
    let serverConfig: ATCOnboardingServerConfigurationProtocol

    var badgeButton = { () -> ATCBadgedButton in
        let button = ATCBadgedButton()
        button.addTarget(self, action: #selector(didTapShoppingCartButton), for: .touchUpInside)
        button.snp.makeConstraints({ (maker) in
            maker.width.equalTo(25)
            maker.height.equalTo(25)
        })
        return button
    }()

    static let cartManager: ATCShoppingCartManager = ATCShoppingCartManager(cart: ATCShoppingCart())
    let cartViewController: ATCShoppingCartViewController
    let ecommerceConfiguration: ATCEcommerceConfiguration
    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    lazy var hostController: ATCHostViewController = { [unowned self] in

        let menuConfiguration = ATCMenuConfiguration(user: nil,
                                                     cellClass: MenuItemCollectionViewCell.self,
                                                     headerHeight: 0,
                                                     items: self.menuItems(user: nil), // We don't have an user at app start
                                                     uiConfig: ATCMenuUIConfiguration())

        let config = ATCHostConfiguration(menuConfiguration: menuConfiguration,
                                          style: .sideBar,
                                          topNavigationRightViews: [badgeButton],
                                          titleView: nil,
                                          topNavigationLeftImage: uiEcommerceConfig.navigationMenuImage,
                                          topNavigationTintColor: nil,
                                          statusBarStyle: uiEcommerceConfig.statusBarStyle,
                                          uiConfig: uiConfig,
                                          pushNotificationsEnabled: false,
                                          locationUpdatesEnabled: false)
        let hostVC = ATCHostViewController(configuration: config,
                                           onboardingCoordinator: dsProvider.onboardingCoordinator(uiConfig: uiConfig),
                                           walkthroughVC: dsProvider.walkthroughVC(uiConfig: uiConfig))
        hostVC.delegate = self
        return hostVC
        }()

    init(configuration: ATCEcommerceConfiguration,
         uiConfig: UIConfiguration,
         dsProvider: ATCEcommerceDataSourceProvider,
         loginManager: ATCFirebaseLoginManager,
         profileManager: ATCFirebaseProfileManager,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         cartManager: ATCShoppingCartManager,
         uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.ecommerceConfiguration = configuration
        self.serverConfig = serverConfig
        self.dsProvider = dsProvider
        self.uiConfig = uiConfig
        self.uiEcommerceConfig = uiEcommerceConfig
        self.homeVC = ATCHomeCollectionViewController.homeViewController(uiConfig: uiConfig,
                                                                         dsProvider: dsProvider,
                                                                         cartManager: cartManager,
                                                                         uiEcommerceConfig: uiEcommerceConfig)
        self.cartViewController = ATCShoppingCartViewController(
            cartManager: ATCShoppingHostViewController.cartManager,
            uiConfig: uiConfig,
            config: ecommerceConfiguration,
            serverConfig: serverConfig,
            placeOrderManager: dsProvider.placeOrderManager,
            uiEcommerceConfig: uiEcommerceConfig,
            dsProvider: dsProvider)
        
        self.categoriesVC = ATCCategoriesViewController(
            dsProvider: dsProvider,
            uiConfig: uiConfig,
            cartManager: cartManager,
            uiEcommerceConfig: uiEcommerceConfig)
        self.profileVC = MyProfileViewController(uiConfig: uiConfig,
                                                 serverConfig: serverConfig,
                                                 cartVC: cartViewController,
                                                 dsProvider: dsProvider,
                                                 loginManager: loginManager,
                                                 manager: profileManager,
                                                 uiEcommerceConfig: uiEcommerceConfig)
        self.searchVC = ATCSearchViewControllerFactory.localSearchViewController(uiConfig: uiConfig, dsProvider: dsProvider, uiEcommerceConfig: uiEcommerceConfig)
        self.ordersVC = ATCOrderViewController(uiConfig: uiConfig,
                                               serverConfig: serverConfig,
                                               cartVC: cartViewController,
                                               dsProvider: dsProvider,
                                               isPastOrdersVC: true)
        
        self.reservationVC = ATCReservationViewControllerFactory().reservationVC(shop: MockStore.shop,
                                                                                 serverConfig: serverConfig,
                                                                                 uiConfig: uiConfig)

        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateCart), name: kATCNotificationDidAddProductToCart, object: nil)
        
        badgeButton.setImage(uiEcommerceConfig.navigationShoppingCartImage, for: .normal)
        badgeButton.setTitleColor(uiEcommerceConfig.navigationBarTitleColor, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewControllerWithView(hostController)
        ATCShoppingHostViewController.cartManager.delegate = cartViewController
        searchVC.searchResultsController.selectionBlock = { (navigationController, object, index) in
            if let product = object as? Product {
                let productVC = ATCProductDetailsViewControllerFactory().productDetailsVC(product: product,
                                                                                          uiConfig: self.uiConfig,
                                                                                          cartManager: ATCShoppingHostViewController.cartManager,
                                                                                          uiEcommerceConfig: self.uiEcommerceConfig)
                self.searchVC.navigationController?.pushViewController(productVC, animated: false)
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return uiEcommerceConfig.statusBarStyle
    }

    fileprivate func menuItems(user: ATCUser?) -> [ATCNavigationItem] {
        let commonItems = [
            ATCNavigationItem(title: "HOME".localizedCore,
                              viewController: homeVC,
                              image: uiEcommerceConfig.menuHomeImage,
                              type: .viewController),
            ATCNavigationItem(title: "MENU".localizedEcommerce,
                              viewController: categoriesVC,
                              image: uiEcommerceConfig.menuRestaurantMenuImage,
                              type: .viewController),
            ATCNavigationItem(title: "SEARCH".localizedCore,
                              viewController: searchVC,
                              image: uiEcommerceConfig.menuSearchImage,
                              type: .viewController),
            ATCNavigationItem(title: "CART".localizedEcommerce,
                              viewController: cartViewController,
                              image: uiEcommerceConfig.navigationShoppingCartImage,
                              type: .viewController),
            ATCNavigationItem(title: "PROFILE".localizedInApp,
                              viewController: profileVC,
                              image: UIImage.localImage("profile-icon", template: true),
                              type: .viewController),
            ATCNavigationItem(title: "RESERVATIONS".localizedEcommerce,
                              viewController: reservationVC,
                              image: uiEcommerceConfig.menuReservationMenuImage,
                              type: .viewController),
            ATCNavigationItem(title: "ORDERS".localizedEcommerce,
                              viewController: ordersVC,
                              image: uiEcommerceConfig.menuOrdersImage,
                              type: .viewController)
        ]
        if let user = user {
            if user.isAdmin {
                self.adminOrdersVC = ATCAdminOrdersViewController.adminOrdersVC(uiConfig: uiConfig,
                                                                                dsProvider: dsProvider,
                                                                                viewer: user,
                                                                                uiEcommerceConfig: uiEcommerceConfig)
                return commonItems + [
                    ATCNavigationItem(title: "ADMIN DASHBOARD".localizedEcommerce,
                                      viewController: adminOrdersVC!,
                                      image: uiEcommerceConfig.menuOrdersImage,
                                      type: .viewController)
                    ] + [
                        ATCNavigationItem(title: "LOGOUT".localizedCore,
                                          viewController: ordersVC,
                                          image: UIImage.localImage("logout-menu-item", template: true),
                                          type: .logout)]
            }
        }
        return commonItems + [
            ATCNavigationItem(title: "LOGOUT".localizedCore,
                              viewController: ordersVC,
                              image: UIImage.localImage("logout-menu-item", template: true),
                              type: .logout)
        ]
    }

    @objc
    private func didTapShoppingCartButton() {
        let cartVC = ATCShoppingCartViewController(cartManager: ATCShoppingHostViewController.cartManager,
                                                   uiConfig: uiConfig,
                                                   config: ecommerceConfiguration,
                                                   serverConfig: serverConfig,
                                                   placeOrderManager: dsProvider.placeOrderManager,
                                                   uiEcommerceConfig: uiEcommerceConfig,
                                                   dsProvider: dsProvider)
        cartVC.user = user
        self.hostController.navigationRootController?.pushViewController(cartVC, animated: true)
    }

    @objc
    private func didUpdateCart() {
        badgeButton.count = ATCShoppingHostViewController.cartManager.numberOfObjects()
    }
}

extension ATCShoppingHostViewController: ATCHostViewControllerDelegate {
    func hostViewController(_ hostViewController: ATCHostViewController, didLogin user: ATCUser) {
        self.user = user
        self.ordersVC.user = user
        self.profileVC.user = user
        self.cartViewController.user = user
    }

    func hostViewController(_ hostViewController: ATCHostViewController, didSync user: ATCUser) {
        self.user = user
        self.ordersVC.user = user
        self.profileVC.user = user
        self.cartViewController.user = user
    }
}
