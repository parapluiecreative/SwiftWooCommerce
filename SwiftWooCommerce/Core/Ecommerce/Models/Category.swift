//
//  Category.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 11/11/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

class Category: ATCStoryViewModel, ATCGenericFirebaseParsable, ATCTextProtocol {
    var text: String {
        return title
    }
    var accessoryText: String?
    let colorString: String?
    let id: String
    var key: String = ""

    required init(jsonDict: [String: Any]) {
        self.id = (jsonDict["id"] as? String) ?? ""
//        self.colorString = (jsonDict["color"] as? String)
        self.colorString = "#000000"//colorString

        super.init(imageURLString: (jsonDict["image_url"] as? String) ?? (jsonDict["photo"] as? String) ?? "",
                   title: (jsonDict["name"] as? String) ?? "",
                   description: (jsonDict["name"] as? String) ?? "")
    }

    convenience required init(key: String, jsonDict: [String: Any]) {
        self.init(jsonDict: jsonDict)
        self.key = key
    }

    required init(wooCommerceDict: [String: Any]) {
        self.id = (String(wooCommerceDict["id"] as? Int ?? 0))
        self.colorString = "#000000"//colorString
        var imageURL = ""
        if let imageDict = wooCommerceDict["image"] as? [String: AnyObject] {
            imageURL = (imageDict["src"] as? String) ?? ""
        }
        super.init(imageURLString: imageURL,
                   title: (wooCommerceDict["name"] as? String) ?? "",
                   description: (wooCommerceDict["description"] as? String) ?? "")
    }

    init(title: String, colorString: String? = nil, id: String, imageURLString: String) {
        self.colorString = "#454545"//colorString
        self.id = id
        super.init(imageURLString: imageURLString, title: title, description: title)
    }
}
