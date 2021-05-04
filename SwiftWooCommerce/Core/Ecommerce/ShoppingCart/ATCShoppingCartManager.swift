//
//  ATCShoppingCartManager.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/8/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Foundation
import PassKit

protocol ATCShoppingCartManagerDelegate: class {
    func cartManagerDidClearProducts(_ cartManager: ATCShoppingCartManager)
    func cartManagerDidAddProduct(_ cartManager: ATCShoppingCartManager)
}

protocol ATCShoppingCartDataSource {
    func object(at index: Int) -> ATCShoppingCartItem
    func numberOfObjects() -> Int
}

class ATCShoppingCartHelper {
    static func persistedCartOrEmpty(with vendorId: String) -> ATCShoppingCart {
        let allSavedCarts = UserDefaults.standard.dictionaryRepresentation().keys
        
        guard let expectedKey = allSavedCarts
            .filter({ $0.contains("com.shopertino.cart.\(vendorId)") })
            .first else {
               return ATCShoppingCart()
        }
        
        let store = ATCDiskPersistenceStore(key: expectedKey)
        if let carts = store.retrieve() as? [ATCShoppingCart],
            carts.count > 0,
            let cart = carts.first {
            return cart
        }
        return ATCShoppingCart()
    }
}

class ATCShoppingCartManager: ATCShoppingCartDataSource {

    var cart: ATCShoppingCart
    weak var delegate: ATCShoppingCartManagerDelegate?

    init(cart: ATCShoppingCart) {
        self.cart = cart
        NotificationCenter.default.addObserver(self, selector: #selector(didCheckOut), name: kATCNotificationDidCheckoutCart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeCart(_:)), name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func ingest(_ cart: ATCShoppingCart, vendorID: String?) {
        self.cart = cart
        self.cart.vendorID = vendorID
        delegate?.cartManagerDidAddProduct(self)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func addProduct(product: ATCShoppingCartProduct,
                    vendorID: String? = nil,
                    quantity: Int = 1,
                    selectedColor: String? = nil,
                    selectedSize: String? = nil) {
        cart.addProduct(product: product,
                        vendorID: vendorID,
                        quantity: quantity,
                        selectedColor: selectedColor,
                        selectedSize: selectedSize)
        let vendorId: [String: String] = ["vendorId": vendorID ?? ""]
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil, userInfo: vendorId)
        delegate?.cartManagerDidAddProduct(self)
    }

    func incrementQuantity(for item: ATCShoppingCartItem) {
        cart.incrementQuantity(for: item)
        let vendorId: [String: String] = ["vendorId": cart.vendorID ?? ""]
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil, userInfo: vendorId)
    }

    func decrementQuantity(for item: ATCShoppingCartItem) {
        cart.decrementQuantity(for: item)
        let vendorId: [String: String] = ["vendorId": cart.vendorID ?? ""]
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil, userInfo: vendorId)
    }

    func update(selectedColor: String, for product: ATCShoppingCartProduct) {
        cart.update(selectedColor: selectedColor, for: product)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func update(selectedSize: String, for product: ATCShoppingCartProduct) {
        cart.update(selectedSize: selectedSize, for: product)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func setProduct(product: ATCShoppingCartProduct, vendorID: String? = nil, quantity: Int = 1) {
        cart.setProduct(product: product, quantity: quantity)
        cart.vendorID = vendorID
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
        delegate?.cartManagerDidAddProduct(self)
    }

    func productCount() -> Int {
        return cart.productCount()
    }

    func distinctProducts() -> [ATCShoppingCartProduct] {
        return cart.distinctProducts()
    }

    func distinctProductCount() -> Int {
        return self.distinctProducts().count
    }

    func distinctProductItems() -> [ATCShoppingCartItem] {
        return cart.distinctProductItems()
    }

    func totalPrice() -> Double {
        return cart.totalPrice()
    }

    func clearProducts() {
        cart.itemDictionary = [:]
        delegate?.cartManagerDidClearProducts(self)
        let vendorId: [String: String] = ["vendorId": cart.vendorID ?? ""]
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil, userInfo: vendorId)
        NotificationCenter.default.post(name: kATCNotificationDidAClearCart, object: nil)
    }

    func applePayItems() -> [PKPaymentSummaryItem] {
        var items: [PKPaymentSummaryItem] = self.distinctProductItems().map({
            let priceStr = String($0.product.cartPrice * Double($0.quantity))
            return PKPaymentSummaryItem(label: $0.product.cartTitle,
                                        amount: NSDecimalNumber(string: priceStr),
                                        type: .final)
        })
        items.append(
            PKPaymentSummaryItem(label: "Total Due".localizedEcommerce,
                                 amount: NSDecimalNumber(floatLiteral: self.totalPrice()),
                                 type: .final)
        )
        return items
    }

    @objc
    fileprivate func didCheckOut() {
        clearProducts()
    }

    @objc
    fileprivate func didChangeCart(_ notification: NSNotification) {
        var vendorId = ""
        if let dict = notification.userInfo as NSDictionary?,
            let id = dict["vendorId"] as? String {
            vendorId = id
        }
        let store = ATCDiskPersistenceStore(key: "com.shopertino.cart.\(vendorId)")
        store.write(object: [cart])
    }

    // MARK: - ATCShoppingCartDataSource

    func object(at index: Int) -> ATCShoppingCartItem {
        return self.distinctProductItems()[index]
    }

    func numberOfObjects() -> Int {
        return self.distinctProductItems().count
    }
}
