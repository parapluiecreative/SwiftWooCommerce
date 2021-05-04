//
//  ATCWalkthroughModel.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/13/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCWalkthroughModel: ATCGenericBaseModel {
    var title: String
    var subtitle: String
    var icon: String

    init(title: String, subtitle: String, icon: String) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    required public init(jsonDict: [String: Any]) {
        fatalError()
    }

    var description: String {
        return title
    }
}
