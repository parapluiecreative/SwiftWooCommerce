//
//  ATCOrderViewControllerFactory.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

let kOrderUpdateNotificationName = NSNotification.Name(rawValue: "kOrderUpdateNotificationName")

class ATCOrderViewController: ATCGenericCollectionViewController {
    var isPastOrdersVC: Bool = false
    var user: ATCUser? {
        didSet {
            if let user = user {
                self.genericDataSource = dsProvider.ordersDataSource(for: user, isPastOrder: isPastOrdersVC)
            }
        }
    }
    let dsProvider: ATCEcommerceDataSourceProvider
    let serverConfig: ATCOnboardingServerConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         cartVC: ATCShoppingCartViewController?,
         dsProvider: ATCEcommerceDataSourceProvider,
         isPastOrdersVC: Bool) {
        self.isPastOrdersVC = isPastOrdersVC
        self.dsProvider = dsProvider
        self.serverConfig = serverConfig
        
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Orders".localizedChat,
                                               description: "You have no orders".localizedChat,
                                               callToAction: nil)
        let config = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                     pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                     collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                     collectionViewLayout: ATCCollectionViewFlowLayout(),
                                                                     collectionPagingEnabled: false,
                                                                     hideScrollIndicators: false,
                                                                     hidesNavigationBar: false,
                                                                     headerNibName: nil,
                                                                     scrollEnabled: true,
                                                                     uiConfig: uiConfig,
                                                                     emptyViewModel: emptyViewModel)
        super.init(configuration: config)
        self.selectionBlock = {[weak self] (navController, object, indexPath) in
            if !isPastOrdersVC {
                guard let `self` = self else { return }
                guard let order = object as? ATCOrder else { return }
                guard let shoppingCart = order.shoppingCart else { return }
                let cartManager = ATCShoppingCartManager(cart: shoppingCart)
                let orderStatusVC = ATCOrderStatusViewController(nibName: "ATCOrderStatusViewController",
                                                                  bundle: nil,
                                                                  uiConfig: uiConfig,
                                                                  serverConfig: self.serverConfig,
                                                                  cartManager: cartManager,
                                                                  order: order,
                                                                  user: self.user,
                                                                  dsProvider: dsProvider)
                self.present(orderStatusVC, animated: true, completion: nil)
            }
        }
        self.use(adapter: OrderRowAdapter(parentVC: self, uiConfig: uiConfig, cartVC: cartVC), for: "ATCOrder")
        self.title = isPastOrdersVC ? "Past Orders".localizedEcommerce : "Orders".localizedEcommerce
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrders), name: kOrderCompleteNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrders), name: kOrderUpdateNotificationName, object: nil)
    }

    @objc private func updateOrders() {
        self.genericDataSource?.loadFirst()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.genericDataSource?.loadFirst()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
