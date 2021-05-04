//
//  ATCShop.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/21/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ATCShop: ATCGenericBaseModel {

    var name: String
    var streetAddress: String
    var imageURLString: String

    convenience required init(jsonDict: [String: Any]) {
        self.init(name: "", imageURLString: "", streetAddress: "")
    }

    init(name: String, imageURLString: String, streetAddress: String) {
        self.name = name
        self.imageURLString = imageURLString
        self.streetAddress = streetAddress
    }

    var description: String {
        return name
    }
}
