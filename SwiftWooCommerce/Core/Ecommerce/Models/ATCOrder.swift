//
//  ATCOrder.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import Firebase
import FirebaseFirestore
import UIKit

class ATCOrderProduct: NSObject, ATCShoppingCartProduct {
    var cartId: String
    var cartTitle: String
    var cartImageURLString: String
    var cartPrice: Double
    var cartColors: [String]
    var cartSizes: [String]
    var selectedColor: String
    var selectedSize: String

    init(cartId: String,
         cartTitle: String,
         cartImageURLString: String,
         cartPrice: Double,
         cartColors: [String],
         cartSizes: [String],
         selectedColor: String,
         selectedSize: String) {
        self.cartId = cartId
        self.cartTitle = cartTitle
        self.cartImageURLString = cartImageURLString
        self.cartPrice = cartPrice
        self.cartColors = cartColors
        self.cartSizes = cartSizes
        self.selectedColor = selectedColor
        self.selectedSize = selectedSize
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(cartId, forKey: "cartId")
        aCoder.encode(cartTitle, forKey: "cartTitle")
        aCoder.encode(cartImageURLString, forKey: "cartImageURLString")
        aCoder.encode(cartPrice, forKey: "cartPrice")
        aCoder.encode(cartColors, forKey: "cartColors")
        aCoder.encode(cartSizes, forKey: "cartSizes")
        aCoder.encode(selectedColor, forKey: "selectedColor")
        aCoder.encode(selectedSize, forKey: "selectedSize")
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(cartId: aDecoder.decodeObject(forKey: "cartId") as? String ?? "",
                  cartTitle: aDecoder.decodeObject(forKey: "cartTitle") as? String ?? "",
                  cartImageURLString: aDecoder.decodeObject(forKey: "cartImageURLString") as? String ?? "",
                  cartPrice: aDecoder.decodeDouble(forKey: "cartPrice"),
                  cartColors: aDecoder.decodeObject(forKey: "cartColors") as? [String] ?? [],
                  cartSizes: aDecoder.decodeObject(forKey: "cartSizes") as? [String] ?? [],
                  selectedColor: aDecoder.decodeObject(forKey: "selectedColor") as? String ?? "",
                  selectedSize: aDecoder.decodeObject(forKey: "selectedSize") as? String ?? ""
        )
    }
}

class ATCOrder: ATCGenericBaseModel {
    var shoppingCart: ATCShoppingCart?
    var createdAt: Date
    var id: String
    var status: String
    var customer: ATCUser?
    var address: ATCAddress?
    var vendorID: String?
    var deliveryType: String?
    var pickUpAddress: ATCAddress?
    var dropAddress: ATCAddress?
    var tripFare: Double?
    var isPaymentCompleted: Bool?

    required convenience init(jsonDict: [String: Any]) {
        let shoppingCart = ATCShoppingCart()
        if let products = jsonDict["products"] as? [[String: Any]] {
            products.forEach { (productItem) in
                let product = ATCOrderProduct(cartId: (productItem["id"] as? String) ?? "",
                                              cartTitle: (productItem["name"] as? String) ?? "",
                                              cartImageURLString: (productItem["photo"] as? String) ?? "",
                                              cartPrice: (productItem["price"] as? Double) ?? Double((productItem["price"] as? String) ?? "0") ??  0.0,
                                              cartColors: (productItem["cartColors"] as? [String]) ?? [],
                                              cartSizes: (productItem["cartSizes"] as? [String]) ?? [],
                                              selectedColor: (productItem["selectedColor"] as? String) ?? "",
                                              selectedSize: (productItem["selectedSize"] as? String) ?? "")
                let quantity = (productItem["quantity"] as? Int) ?? 0
                shoppingCart.addProduct(product: product,
                                        quantity: quantity,
                                        selectedColor: product.selectedColor,
                                        selectedSize: product.selectedSize)
            }
        }
        var customer: ATCUser? = nil
        if let customerDict = jsonDict["author"] as? [String: Any] {
            customer = ATCUser(representation: customerDict)
        } else if let customerDict = jsonDict["user"] as? [String: Any] {
            customer = ATCUser(representation: customerDict)
        }
        var address: ATCAddress? = nil
        if let addressDict = jsonDict["address"] as? [String: Any] {
            address = ATCAddress(jsonDict: addressDict)
        }
        var pickUpAddress: ATCAddress? = nil
        if let addressDict = jsonDict["pickUpAddress"] as? [String: Any] {
            pickUpAddress = ATCAddress(jsonDict: addressDict)
        }
        var dropAddress: ATCAddress? = nil
        if let addressDict = jsonDict["dropAddress"] as? [String: Any] {
            dropAddress = ATCAddress(jsonDict: addressDict)
        }
        let tripFare: Double? = jsonDict["tripFare"] as? Double
        let isPaymentCompleted: Bool? = jsonDict["isPaymentCompleted"] as? Bool
        let vendorID: String? = jsonDict["vendorID"] as? String
        shoppingCart.vendorID = vendorID

        let deliveryType: String? = jsonDict["deliveryType"] as? String
        
        var createdAt: Date? = (jsonDict["createdAt"] as? Date)
        if createdAt == nil {
            if let timestamp = jsonDict["createdAt"] as? Timestamp {
                createdAt = timestamp.dateValue() as Date
            }
        }

        self.init(id: jsonDict["id"] as? String ?? NSUUID().uuidString,
                  shoppingCart: shoppingCart,
                  customer: customer,
                  address: address,
                  status: jsonDict["status"] as? String ?? "",
                  createdAt: createdAt ?? Date(),
                  vendorID: vendorID,
                  deliveryType: deliveryType,
                  pickUpAddress: pickUpAddress,
                  dropAddress: dropAddress,
                  tripFare: tripFare,
                  isPaymentCompleted: isPaymentCompleted)
    }

    init(id: String,
         shoppingCart: ATCShoppingCart,
         customer: ATCUser?,
         address: ATCAddress?,
         status: String,
         createdAt: Date,
         vendorID: String? = nil,
         deliveryType: String? = nil,
         pickUpAddress: ATCAddress? = nil,
         dropAddress: ATCAddress? = nil,
         tripFare: Double? = nil,
         isPaymentCompleted: Bool? = nil) {
        self.id = id
        self.status = status
        self.shoppingCart = shoppingCart
        self.customer = customer
        self.createdAt = createdAt
        self.address = address
        self.vendorID = vendorID
        self.deliveryType = deliveryType
        self.pickUpAddress = pickUpAddress
        self.dropAddress = dropAddress
        self.tripFare = tripFare
        self.isPaymentCompleted = isPaymentCompleted
    }

    required init(wooCommerceDict: [String: Any]) {
        self.id = (String(wooCommerceDict["id"] as? Int ?? 0))
        //        self.createdAt = ((wooCommerceDict["date_created"] as? String) ?? "")
        self.createdAt = Date()
        self.status = (wooCommerceDict["status"] as? String) ?? ""
        self.shoppingCart = ATCShoppingCart()
        if let lineItems = wooCommerceDict["line_items"] as? [[String: Any]] {
            lineItems.forEach { (lineItemDict) in
                guard let metadata = lineItemDict["meta_data"] as? [[String: Any]] else {
                    return
                }
                let product = Product(title: lineItemDict["name"] as? String ?? "No name",
                                      price: "\(lineItemDict["price"] as? Double ?? 0)",
                                      images: [],
                                      colors: [],
                                      sizes: [],
                                      id: lineItemDict["product_id"] as? String ?? "No ID",
                                      imageURLString: ATCWooCommerceUtil.metadataValue(for: "imageURLString", metaData: metadata) ?? "",
                                      productDescription: "")
                shoppingCart?.addProduct(product: product,
                                         vendorID: nil,
                                         quantity: (lineItemDict["quantity"] as? Int) ?? 0,
                                         selectedColor: ATCWooCommerceUtil.metadataValue(for: "color", metaData: metadata),
                                         selectedSize: ATCWooCommerceUtil.metadataValue(for: "size", metaData: metadata))
            }
        }
        if let addressDict = wooCommerceDict["billing"] as? [String: Any] {
            self.address = ATCAddress(jsonDict: addressDict)
        }
    }

    func orderOptions() -> [CPKSelectOptionModel] {
        return ATCOrderStatus.allCases.map { CPKSelectOptionModel(title: $0.status,
                                                                  selected: $0.checkSelectedItem(by: status)) }
    }

    func headerImageURL() -> URL? {
        if let firstProductURL = shoppingCart?.distinctProducts().first?.cartImageURLString {
            return URL(string: firstProductURL)
        }
        return nil
    }

    func totalItems() -> Int {
        if let shoppingCart = shoppingCart {
            return shoppingCart.distinctProductItems().count
        }
        return 0
    }

    func totalPrice() -> Double? {
        return shoppingCart?.totalPrice()
    }

    var description: String {
        return ""
    }
}
