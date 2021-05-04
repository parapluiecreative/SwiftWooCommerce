//
//  ATCShoppingCart.swift
//  Shopertino
//
//  Created by Duy Bui on 7/22/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Foundation

class ATCShoppingCart: NSObject, NSCoding, ATCPersistable {
    var itemDictionary = [String: ATCShoppingCartItem]()
    var vendorID: String? = nil
    var webUrl: String?

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(itemDictionary, forKey: "itemDictionary")
        if let vendorID = vendorID {
            aCoder.encode(vendorID, forKey: "vendorID")
        }
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        if let dict = aDecoder.decodeObject(forKey: "itemDictionary") as? [String: ATCShoppingCartItem] {
            itemDictionary = dict
        }
        vendorID = aDecoder.decodeObject(forKey: "vendorID") as? String
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
                    quantity: Int = 1,
                    selectedColor: String? = nil,
                    selectedSize: String? = nil) {
        var q = quantity
        if let item = itemDictionary[product.cartId] {
            q = item.quantity + quantity
        }
        self.vendorID = vendorID
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
                    "vendorID": vendorID]
        }
        return ["products": products]
    }

    var diffIdentifier: String {
        return "persistedCart"
    }
}
