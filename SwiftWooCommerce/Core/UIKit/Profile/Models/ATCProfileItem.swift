//
//  ATCProfileItem.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/2/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

public enum ATCProfileItemType {
    case none
    case arrow
}

public class ATCProfileItem: ATCGenericBaseModel {
    var icon: UIImage?
    var title: String
    var type: ATCProfileItemType
    var color: UIColor

    init(icon: UIImage? = nil, title: String, type: ATCProfileItemType, color: UIColor) {
        self.icon = icon
        self.title = title
        self.type = type
        self.color = color
    }

    required public init(jsonDict: [String: Any]) {
        fatalError()
    }

    public var description: String {
        return title
    }
}
