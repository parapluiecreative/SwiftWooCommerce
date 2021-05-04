//
//  ATCFormTextFieldModel.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCFormTextFieldViewModel: ATCGenericBaseModel {
    var title: String
    var identifier: String

    init(title: String, identifier: String) {
        self.title = title
        self.identifier = identifier
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }

    var description: String {
        return title
    }
}
