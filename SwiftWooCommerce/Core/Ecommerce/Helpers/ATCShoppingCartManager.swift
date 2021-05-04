//
//  ATCShoppingCartManager.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/8/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Foundation
import PassKit

let kATCNotificationDidAddProductToCart = NSNotification.Name(rawValue: "kATCNotificationDidAddProductToCart")
let kATCNotificationDidAClearCart = NSNotification.Name(rawValue: "kATCNotificationDidAClearCart")
let kATCNotificationDidCheckoutCart = NSNotification.Name(rawValue: "kATCNotificationDidCheckoutCart")

protocol ATCShoppingCartProduct: NSCoding {
    var cartId: String {get}
    var cartTitle: String {get}
    var cartImageURLString: String {get}
    var cartPrice: Double {get}
    var cartColors: [String] {get}
    var cartSizes: [String] {get}
}

class ATCShoppingCartItem: NSObject, ATCGenericBaseModel, NSCoding {
    var product: ATCShoppingCartProduct
    var quantity: Int
    var selectedColor: String?
    var selectedSize: String?

    override var description: String {
        return product.cartTitle
    }

    convenience required init(jsonDict: [String: Any]) {
        self.init(product: Product(jsonDict: [:]), quantity: 0, selectedColor: nil, selectedSize: nil)
    }

    init(product: ATCShoppingCartProduct, quantity: Int, selectedColor: String?, selectedSize: String?) {
        self.product = product
        self.quantity = quantity
        self.selectedColor = selectedColor
        self.selectedSize = selectedSize
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(product, forKey: "product")
        aCoder.encode(quantity, forKey: "quantity")
        aCoder.encode(selectedColor, forKey: "selectedColor")
        aCoder.encode(selectedSize, forKey: "selectedSize")
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(product: aDecoder.decodeObject(forKey: "product") as? Product ?? MockStore.products[0],
                  quantity: aDecoder.decodeInteger(forKey: "quantity"),
                  selectedColor: aDecoder.decodeObject(forKey: "selectedColor") as? String ?? "",
                  selectedSize: aDecoder.decodeObject(forKey: "selectedSize") as? String ?? ""
        )
    }
}

class ATCShoppingCart: NSObject, NSCoding, ATCPersistable {
    var itemDictionary = [String: ATCShoppingCartItem]()
    var vendorID: String? = nil
    var vendor: ATCVendor? = nil
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(itemDictionary, forKey: "itemDictionary")
        if let vendorID = vendorID {
            aCoder.encode(vendorID, forKey: "vendorID")
        }
        if let vendor = vendor {
            aCoder.encode(vendor, forKey: "vendor")
        }
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        if let dict = aDecoder.decodeObject(forKey: "itemDictionary") as? [String: ATCShoppingCartItem] {
            itemDictionary = dict
        }
        vendorID = aDecoder.decodeObject(forKey: "vendorID") as? String
        if let dict = aDecoder.decodeObject(forKey: "vendor") as? ATCVendor {
            vendor = dict
        }
    }

    func productCount() -> Int {
        return itemDictionary.reduce(0) { (x, entry: (key: String, value: ATCShoppingCartItem)) -> Int in
            return x + entry.value.quantity
        }
    }

    func distinctProducts() -> [ATCShoppingCartProduct] {
        return itemDictionary.values.map({$0.product})
    }

    func distinctProductItems() -> [ATCShoppingCartItem] {
        return itemDictionary.values.map({$0})
    }

    func totalPrice() -> Double {
        return itemDictionary.reduce(0.0) { (x, entry: (key: String, value: ATCShoppingCartItem)) -> Double in
            return x + Double(entry.value.quantity) * entry.value.product.cartPrice
        }.twoDecimals()
    }

    func addProduct(product: ATCShoppingCartProduct,
                    vendorID: String? = nil,
                    vendor: ATCVendor? = nil,
                    quantity: Int = 1,
                    selectedColor: String? = nil,
                    selectedSize: String? = nil) {
        var q = quantity
        if let item = itemDictionary[product.cartId] {
            q = item.quantity + quantity
        }
        self.vendorID = vendorID
        self.vendor = vendor
        setProduct(product: product, quantity: q, selectedColor: selectedColor, selectedSize: selectedSize)
    }

    func incrementQuantity(for item: ATCShoppingCartItem) {
        if let item = itemDictionary[item.product.cartId] {
            setProduct(product: item.product, quantity: item.quantity + 1, selectedColor: item.selectedColor, selectedSize: item.selectedSize)
        }
    }

    func decrementQuantity(for item: ATCShoppingCartItem) {
        if let item = itemDictionary[item.product.cartId] {
            let newQuantity = item.quantity - 1
            if newQuantity > 0 {
                setProduct(product: item.product, quantity: item.quantity - 1, selectedColor: item.selectedColor, selectedSize: item.selectedSize)
            } else {
                itemDictionary[item.product.cartId] = nil
            }
        }
    }

    func setProduct(product: ATCShoppingCartProduct, quantity: Int = 1, selectedColor: String? = nil, selectedSize: String? = nil) {
        if quantity <= 0 {
            itemDictionary[product.cartId] = nil
            // Remove action
            return
        }
        itemDictionary[product.cartId] = ATCShoppingCartItem(product: product,
                                                             quantity: quantity,
                                                             selectedColor: selectedColor,
                                                             selectedSize: selectedSize)
    }

    func update(selectedColor: String, for product: ATCShoppingCartProduct) {
        if let item = itemDictionary[product.cartId] {
            itemDictionary[product.cartId] = ATCShoppingCartItem(product: product, quantity: item.quantity, selectedColor: selectedColor, selectedSize: item.selectedSize)
        }
    }

    func update(selectedSize: String, for product: ATCShoppingCartProduct) {
        if let item = itemDictionary[product.cartId] {
            itemDictionary[product.cartId] = ATCShoppingCartItem(product: product, quantity: item.quantity, selectedColor: item.selectedColor, selectedSize: selectedSize)
        }
    }

    func representation() -> [String: Any] {
        var products: [[String: Any]] = []
        itemDictionary.forEach { (arg) in
            let (key, cartItem) = arg
            products.append([
                "quantity": cartItem.quantity,
                "selectedColor": cartItem.selectedColor ?? "",
                "selectedSize": cartItem.selectedSize ?? "",
                "cartColors": cartItem.product.cartColors,
                "cartSizes": cartItem.product.cartSizes,
                "id": cartItem.product.cartId,
                "name": cartItem.product.cartTitle,
                "photo": cartItem.product.cartImageURLString,
                "price": Double(cartItem.quantity) * cartItem.product.cartPrice
            ])
        }
        if let vendorID = vendorID {
            return ["products": products,
                    "vendorID": vendorID,
                    "vendor": vendor?.representation()]
        }
        return ["products": products]
    }

    var diffIdentifier: String {
        return "persistedCart"
    }
}

protocol ATCShoppingCartManagerDelegate: class {
    func cartManagerDidClearProducts(_ cartManager: ATCShoppingCartManager)
    func cartManagerDidAddProduct(_ cartManager: ATCShoppingCartManager)
}

protocol ATCShoppingCartDataSource {
    func object(at index: Int) -> ATCShoppingCartItem
    func numberOfObjects() -> Int
}

class ATCShoppingCartManager: ATCShoppingCartDataSource {

    class var persistedCartOrEmpty: ATCShoppingCart {
        let store = ATCDiskPersistenceStore(key: "com.shopertino.cart")
        if let carts = store.retrieve() as? [ATCShoppingCart],
            carts.count > 0,
            let cart = carts.first {
            return cart
        }
        return ATCShoppingCart()
    }

    var cart: ATCShoppingCart
    weak var delegate: ATCShoppingCartManagerDelegate?

    init(cart: ATCShoppingCart) {
        self.cart = cart
        NotificationCenter.default.addObserver(self, selector: #selector(didCheckOut), name: kATCNotificationDidCheckoutCart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeCart), name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func ingest(_ cart: ATCShoppingCart, vendorID: String?) {
        self.cart = cart
        self.cart.vendorID = vendorID
        delegate?.cartManagerDidAddProduct(self)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func addProduct(product: ATCShoppingCartProduct,
                    vendorID: String? = nil,
                    vendor: ATCVendor?,
                    quantity: Int = 1,
                    selectedColor: String? = nil,
                    selectedSize: String? = nil) {
        cart.addProduct(product: product,
                        vendorID: vendorID,
                        vendor: vendor,
                        quantity: quantity,
                        selectedColor: selectedColor,
                        selectedSize: selectedSize)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
        delegate?.cartManagerDidAddProduct(self)
    }

    func incrementQuantity(for item: ATCShoppingCartItem) {
        cart.incrementQuantity(for: item)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func decrementQuantity(for item: ATCShoppingCartItem) {
        cart.decrementQuantity(for: item)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func update(selectedColor: String, for product: ATCShoppingCartProduct) {
        cart.update(selectedColor: selectedColor, for: product)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func update(selectedSize: String, for product: ATCShoppingCartProduct) {
        cart.update(selectedSize: selectedSize, for: product)
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
    }

    func setProduct(product: ATCShoppingCartProduct, vendorID: String? = nil, vendor: ATCVendor?, quantity: Int = 1) {
        cart.setProduct(product: product, quantity: quantity)
        cart.vendorID = vendorID
        cart.vendor = vendor
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
        NotificationCenter.default.post(name: kATCNotificationDidAddProductToCart, object: nil)
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
    fileprivate func didChangeCart() {
        let store = ATCDiskPersistenceStore(key: "com.shopertino.cart")
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
