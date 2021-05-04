//
//  ATCBarChartAdapter.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import ChameleonFramework
import Charts
import UIKit

class ATCStaticLabelFormatter: IAxisValueFormatter {
    let labels: [String]
    init(labels: [String]) {
        self.labels = labels
    }

    func stringForValue(_ value: Double,
                        axis: AxisBase?) -> String {
        if let entries = axis?.entries {
            for (i, entry) in entries.enumerated() {
                if entry + 1 == value && i < labels.count {
                    return labels[i]
                }
            }
        }
        return String(Int(value))
    }
}

class ATCBarChartAdapter: ATCGenericCollectionRowAdapter, ChartViewDelegate {
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let chart = object as? ATCBarChart,
            let cell = cell as? ATCBarChartCollectionViewCell,
            let chartView = cell.barChartView {

            // Legend configuration
            let l = chartView.legend
            l.horizontalAlignment = .center
            l.verticalAlignment = .bottom
            l.orientation = .horizontal
            l.font = uiConfig.regularSmallFont
            l.yOffset = 10
            l.xOffset = 10
            l.yEntrySpace = 0
            l.textColor = uiConfig.mainTextColor

            // Data sets & colors
            let color = uiConfig.mainThemeForegroundColor
            let colors = NSArray(ofColorsWith: ColorScheme.analogous, with: color, flatScheme: false) as! [NSUIColor]

            let dataSets = chart.groups.enumerated().map { (index, group) -> BarChartDataSet in
                let numbers = group.numbers
                var entries: [BarChartDataEntry] = []
                for (index, label) in chart.labels.enumerated() {
                    entries.append(BarChartDataEntry(x: Double(index), y: numbers[index]))
                }
                let ds = BarChartDataSet(entries: entries, label: group.name)
                let idx = index % colors.count
                let c = colors[idx]
                ds.setColor(c)
                ds.valueFormatter = MyFormatter(format: chart.valueFormat)
                return ds
            }

            let data = BarChartData(dataSets: dataSets)
            data.setValueFormatter(MyFormatter(format: ""))

            if (dataSets.count > 1) {
                let groupSpace = 0.08
                let barSpace = 0.03
                let xAxis = chartView.xAxis
                xAxis.labelFont = uiConfig.regularSmallFont
                xAxis.labelTextColor = uiConfig.mainTextColor
                xAxis.granularity = 1
                xAxis.centerAxisLabelsEnabled = true
                data.barWidth = 0.1
                xAxis.axisMinimum = Double(0)
                xAxis.valueFormatter = ATCStaticLabelFormatter(labels: chart.labels)
                xAxis.axisMaximum = Double(0) + data.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(chart.labels.count)
                data.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
            }

            chartView.data = data

            chartView.pinchZoomEnabled = false
            chartView.dragEnabled = false
//            chartView.setScaleEnabled(false)
            chartView.delegate = self

            chartView.xAxis.drawGridLinesEnabled = false
            chartView.xAxis.labelPosition = .bottom
            chartView.rightAxis.enabled = false
            chartView.leftAxis.drawGridLinesEnabled = true
            chartView.leftAxis.axisMinimum = 0
            chartView.leftAxis.labelTextColor = uiConfig.mainTextColor

            chartView.chartDescription?.enabled =  false

            chartView.pinchZoomEnabled = false
            chartView.drawBarShadowEnabled = false

            chartView.notifyDataSetChanged()
            cell.barChartView.backgroundColor = uiConfig.mainThemeBackgroundColor
            cell.setNeedsLayout()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCBarChartCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let _ = object as? ATCBarChart else { return .zero }
        return CGSize(width: containerBounds.width / 2, height: 300)
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Asda")
    }
}
