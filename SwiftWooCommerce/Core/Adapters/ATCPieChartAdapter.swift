//
//  ATCPieChartAdapter.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/1/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import ChameleonFramework
import Charts
import UIKit

class MyFormatter: IValueFormatter {
    let format: String
    init(format: String) {
        self.format = format
    }
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(format: format, value)
    }
}

class ATCPieChartAdapter: ATCGenericCollectionRowAdapter, ChartViewDelegate {

    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let pieChart = object as? ATCPieChart,
            let cell = cell as? ATCPieChartCollectionViewCell,
            let chartView = cell.pieChartView {

            let dataSet = PieChartDataSet(entries: pieChart.entries, label: pieChart.name)
            let data = PieChartData(dataSet: dataSet)
            chartView.data = data

            let color = uiConfig.mainThemeForegroundColor
            dataSet.colors = NSArray(ofColorsWith: ColorScheme.analogous, with: color, flatScheme: false) as! [NSUIColor]
            dataSet.valueFormatter = MyFormatter(format: pieChart.format)

            chartView.backgroundColor = uiConfig.mainThemeBackgroundColor
            chartView.drawHoleEnabled = false
            chartView.legend.textColor = uiConfig.mainTextColor
            chartView.legend.direction = .rightToLeft
            chartView.legend.font = uiConfig.regularMediumFont
            chartView.legend.textColor = uiConfig.mainThemeForegroundColor
            chartView.legend.enabled = false

            chartView.chartDescription?.font = uiConfig.regularLargeFont
            chartView.chartDescription?.text = pieChart.descriptionText
//            chartView.chartDescription?.xOffset = chartView.frame.width
//            chartView.chartDescription?.yOffset = chartView.frame.height * (2/3)
            chartView.chartDescription?.textAlign = NSTextAlignment.right
            chartView.chartDescription?.textColor = uiConfig.mainThemeForegroundColor
//            chartView.chartDescription?.text = ""
            chartView.setExtraOffsets(left: -10, top: -10, right: -10, bottom: -15)
            chartView.notifyDataSetChanged()
            cell.setNeedsLayout()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCPieChartCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let pieChart = object as? ATCPieChart else { return .zero }
        return CGSize(width: containerBounds.width / 2, height: 180)
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Asda")
    }
}
