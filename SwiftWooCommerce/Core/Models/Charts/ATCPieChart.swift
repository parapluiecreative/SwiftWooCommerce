//
//  ATCPieChart.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/1/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import Charts
import UIKit

class ATCPieChart: ATCGenericBaseModel {
    let entries: [PieChartDataEntry]
    let name: String
    let descriptionText: String?
    let format: String

    init(entries: [PieChartDataEntry], name: String, format: String, descriptionText: String? = nil) {
        self.entries = entries
        self.name = name
        self.descriptionText = descriptionText
        self.format = format
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }

    var description: String {
        return name
    }
}
