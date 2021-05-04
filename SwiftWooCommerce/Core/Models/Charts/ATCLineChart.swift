//
//  ATCLineChart.swift
//  DashboardApp
//
//  Created by Florian Marcu on 7/28/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import Charts
import UIKit

class ATCLineChart: ATCGenericBaseModel {
    let numbers: [Double]
    let name: String

    init(numbers: [Double], name: String) {
        self.numbers = numbers
        self.name = name
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }

    var description: String {
        return ""
    }
}
