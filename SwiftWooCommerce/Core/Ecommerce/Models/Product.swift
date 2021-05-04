//
//  Product.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 10/15/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Foundation
import UIKit

protocol ProductTypeProtocol: ATCGenericBaseModel {
    var imageURLString: String {get}
    var title: String {get}
    var price: String {get}
}

class Product: NSObject, ATCShoppingCartProduct, ProductTypeProtocol, ATCGenericFirebaseParsable, ATCGenericSearchable, ATCPersistable {
    override var description: String {
        return title
    }

    var imageURLString: String
    var title: String
    var price: String
    var images: [String]
    var colors: [String]
    var sizes: [String]
    var productDescription: String
    var id: String
    var key: String = ""
    var vendorID: String?
    
    // Uploading part
    var uploadImages: [UIImage]?
    var categoryID: String?
    
    required init(jsonDict: [String: Any]) {
        self.imageURLString = (jsonDict["image_url"] as? String) ?? (jsonDict["photo"] as? String) ?? ""
        self.title = (jsonDict["name"] as? String) ?? ""
        self.price = (jsonDict["price"] as? String) ?? String(describing: (jsonDict["price"] as? Double) ?? 0)
        self.productDescription = (jsonDict["description"] as? String) ?? ""
        self.images = (jsonDict["images"] as? [String]) ?? (jsonDict["details"] as? [String]) ?? (jsonDict["photos"] as? [String]) ?? [String]()
        self.colors = (jsonDict["colors"] as? [String]) ?? [String]()
        self.sizes = (jsonDict["sizes"] as? [String]) ?? ["XS", "S", "M"]
        self.id = (jsonDict["id"] as? String) ?? ""
        self.vendorID = jsonDict["vendorID"] as? String
        self.categoryID = jsonDict["category"] as? String
    }
    
    required convenience init(key: String, jsonDict: [String: Any]) {
        self.init(jsonDict: jsonDict)
        self.key = key
    }
    
    init(title: String,
         price: String,
         images: [String],
         colors: [String],
         sizes: [String],
         id: String,
         imageURLString: String,
         productDescription: String,
         vendorID: String? = nil) {
        self.title = title
        self.price = price
        self.images = images
        self.id = id
        self.colors = colors
        self.sizes = sizes
        self.imageURLString = imageURLString
        self.productDescription = productDescription
        self.vendorID = vendorID
    }
    
    // fresh initialization
    override init() {
        self.imageURLString = ""
        self.title = ""
        self.price = ""
        self.images = []
        self.colors = []
        self.sizes = []
        self.productDescription = ""
        self.id = ""
    }

    required init(wooCommerceDict: [String: Any]) {
        self.id = (String(wooCommerceDict["id"] as? Int ?? 0))
        self.title = (wooCommerceDict["name"] as? String) ?? ""
        self.productDescription = (wooCommerceDict["description"] as? String) ?? ""
        self.price = (wooCommerceDict["price"] as? String) ?? ""
        var colors: [String] = []
        var sizes: [String] = []
        if let attributes = wooCommerceDict["attributes"] as? [[String: Any]] {
            colors = Product.colorsFromWooAttributes(attributes)
            sizes = Product.sizesFromWooAttributes(attributes)
        }
        self.colors = colors
        self.sizes = sizes
        var images: [String] = []
        if let imagesList = wooCommerceDict["images"] as? [[String: Any]] {
            for imageDict in imagesList {
                if let imageURL = imageDict["src"] as? String {
                    images.append(imageURL)
                }
            }
        }
        self.images = images
        self.imageURLString = (images.count > 0) ? images[0] : ""
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(images, forKey: "images")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(colors, forKey: "colors")
        aCoder.encode(sizes, forKey: "sizes")
        if let vendorID = vendorID {
            aCoder.encode(vendorID, forKey: "vendorID")
        }
        aCoder.encode(imageURLString, forKey: "imageURLString")
        aCoder.encode(productDescription, forKey: "productDescription")
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(title: aDecoder.decodeObject(forKey: "title") as? String ?? "unknown",
                  price: aDecoder.decodeObject(forKey: "price") as? String ?? "unknown",
                  images: aDecoder.decodeObject(forKey: "images") as? [String] ?? [],
                  colors: aDecoder.decodeObject(forKey: "colors") as? [String] ?? [],
                  sizes: aDecoder.decodeObject(forKey: "sizes") as? [String] ?? [],
                  id: aDecoder.decodeObject(forKey: "id") as? String ?? "unknown",
                  imageURLString: aDecoder.decodeObject(forKey: "imageURLString") as? String ?? "unknown",
                  productDescription: aDecoder.decodeObject(forKey: "productDescription") as? String ?? "unknown",
                  vendorID: aDecoder.decodeObject(forKey: "vendorID") as? String
        )
    }

    // MARK: - ATCShoppingCartProduct

    var cartId: String {
        return id
    }

    var cartTitle: String {
        return title
    }

    var cartImageURLString: String {
        return imageURLString
    }

    var cartPrice: Double {
        return Double(price) ?? 0
    }

    var cartColors: [String] {
        return colors
    }

    var cartSizes: [String] {
        return sizes
    }

    // MARK: - ATCPersistable

    var diffIdentifier: String {
        return id
    }

    // MARK: - ATCGenericSearchable

    func matches(keyword: String) -> Bool {
        let str = self.title.lowercased()
        if str.contains(keyword.lowercased()) {
            return true
        }
        return false
    }

    private static func colorsFromWooAttributes(_ attributes: [[String: Any]]) -> [String] {
        for dict in attributes {
            if let name = dict["name"] as? String, let options = dict["options"] as? [String] {
                if (name.uppercased() == "COLOR") {
                    return options.map({$0.naturalColorNameToHexString()})
                }
            }
        }
        return []
    }

    private static func sizesFromWooAttributes(_ attributes: [[String: Any]]) -> [String] {
        for dict in attributes {
            if let name = dict["name"] as? String, let options = dict["options"] as? [String] {
                if (name.uppercased() == "SIZE") {
                    return options
                }
            }
        }
        return []
    }
}
