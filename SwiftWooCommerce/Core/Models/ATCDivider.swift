//
//  ATCDivider.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/19/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ATCDivider: ATCGenericBaseModel {

    var title: String?

    convenience init(_ title: String? = nil) {
        self.init(jsonDict: [:])
        self.title = title
    }

    required init(jsonDict: [String: Any]) {}
    var description: String {
        return "divider"
    }
}
