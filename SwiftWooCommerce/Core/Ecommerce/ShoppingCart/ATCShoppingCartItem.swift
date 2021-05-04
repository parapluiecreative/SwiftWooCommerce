//
//  ATCShoppingCartItem.swift
//  Shopertino
//
//  Created by Duy Bui on 7/22/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Foundation

let kATCNotificationDidAddProductToCart = NSNotification.Name(rawValue: "kATCNotificationDidAddProductToCart")
let kATCNotificationDidAClearCart = NSNotification.Name(rawValue: "kATCNotificationDidAClearCart")
let kATCNotificationDidCheckoutCart = NSNotification.Name(rawValue: "kATCNotificationDidCheckoutCart")
let kATCNotificationDidUpdateCartManager = NSNotification.Name(rawValue: "kATCNotificationDidUpdateCartManager")

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
