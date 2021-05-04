//
//  ATCText.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCTextProtocol {
    var text: String {get}
    var accessoryText: String? {get}
}

protocol ATCTextWithStyleProtocol: ATCTextProtocol {
    var textFont: UIFont? {get}
    var textColor: UIColor? {get}
}

class ATCText: ATCGenericBaseModel, ATCTextWithStyleProtocol {

    var text: String
    var accessoryText: String?
    var textFont: UIFont?
    var textColor: UIColor?

    init(text: String, accessoryText: String? = nil, textFont: UIFont? = nil, textColor: UIColor? = nil) {
        self.text = text
        self.accessoryText = accessoryText
        self.textFont = textFont
        self.textColor = textColor
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }

    var description: String {
        return text
    }
}
