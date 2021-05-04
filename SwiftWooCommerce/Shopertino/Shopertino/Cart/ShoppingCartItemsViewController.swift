//
//  ShoppingCartItemsViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/7/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ShoppingCartItemsViewControllerDelegate: class {
    func itemsViewControllerDidUpdateQuantities(_ vc: ShoppingCartItemsViewController)
}

class ShoppingCartItemsViewController: ATCGenericCollectionViewController {
    var cartManager: ATCShoppingCartManager
    weak var delegate: ShoppingCartItemsViewControllerDelegate?

    init(cartManager: ATCShoppingCartManager,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        self.cartManager = cartManager

        let layout = ATCCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let emptyViewModel = CPKEmptyViewModel(image: nil, title: "No Cart Items".localizedInApp, description: "There are no items in your shopping cart.".localizedInApp, callToAction: nil)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: emptyViewModel)
        super.init(configuration: configuration)
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: cartManager.distinctProductItems())
        let adapter = ShoppingCartItemRowAdapter(uiConfig: uiConfig, hostViewController: self)
        adapter.delegate = self
        self.use(adapter: adapter, for: "ATCShoppingCartItem")
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateCartManager), name: kATCNotificationDidUpdateCartManager, object: nil)
    }
    
    @objc
    func didUpdateCartManager() {
        update()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.darkModeColor(hexString: "#fafafa")
    }

    func update() {
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: cartManager.distinctProductItems())
        self.genericDataSource?.loadFirst()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShoppingCartItemsViewController: ShoppingCartItemRowAdapterDelegate {
    func shoppingCartRowAdapter(_ adapter: ShoppingCartItemRowAdapter, didIncreaseQuantityFor item: ATCShoppingCartItem) {
        cartManager.incrementQuantity(for: item)
        self.delegate?.itemsViewControllerDidUpdateQuantities(self)
    }

    func shoppingCartRowAdapter(_ adapter: ShoppingCartItemRowAdapter, didDecreaseQuantityFor item: ATCShoppingCartItem) {
        if (item.quantity == 1) {
            let alert = UIAlertController(title: "Remove from cart?".localizedInApp, message: "This product will be removed from cart.".localizedInApp, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Remove".localizedInApp, style: .destructive, handler: { (action) in
                self.cartManager.decrementQuantity(for: item)
                self.delegate?.itemsViewControllerDidUpdateQuantities(self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel".localizedInApp, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            cartManager.decrementQuantity(for: item)
            self.delegate?.itemsViewControllerDidUpdateQuantities(self)
        }
    }

    func shoppingCartRowAdapter(_ adapter: ShoppingCartItemRowAdapter, didSelectColor color: String, for item: ATCShoppingCartItem) {
        cartManager.update(selectedColor: color, for: item.product)
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: cartManager.distinctProductItems())
        self.genericDataSource?.loadFirst()
    }

    func shoppingCartRowAdapter(_ adapter: ShoppingCartItemRowAdapter, didSelectSize size: String, for item: ATCShoppingCartItem) {
        cartManager.update(selectedSize: size, for: item.product)
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: cartManager.distinctProductItems())
        self.genericDataSource?.loadFirst()
    }
}
