//
//  ATCDatedLineChartViewController.swift
//  FinanceApp
//
//  Created by Florian Marcu on 3/10/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Charts
import UIKit

class ATCChartDate {
    let title: String
    let startDate: Date
    let endDate: Date

    init(title: String, startDate: Date, endDate: Date = Date()) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
}

class ATCDateList {
    let dates: [ATCChartDate]

    init(dates: [ATCChartDate]) {
        self.dates = dates
    }
}

protocol ATCDatedLineChartViewControllerDelegate: class {
    func datedLineChartViewController(_ viewController: ATCDatedLineChartViewController,
                                      didSelect chartDate: ATCChartDate,
                                      titleLabel: UILabel,
                                      chartView: LineChartView ) -> Void
}

class ATCDatedLineChartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var datesTableView: UICollectionView!
    @IBOutlet var chartContainerView: UIView!
    @IBOutlet var chartView: LineChartView!
    @IBOutlet var titleLabel: UILabel!

    weak var delegate: ATCDatedLineChartViewControllerDelegate?
    private let uiConfig: ATCUIGenericConfigurationProtocol
    private let dateList: ATCDateList
    private var selectedDate: ATCChartDate

    init(dateList: ATCDateList, uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
        self.dateList = dateList
        self.selectedDate = dateList.dates[0]
        super.init(nibName: "ATCDatedLineChartViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        datesTableView.delegate = self
        datesTableView.dataSource = self
        datesTableView.isScrollEnabled = false
        containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        datesTableView.backgroundColor = uiConfig.mainThemeBackgroundColor
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        datesTableView.collectionViewLayout = layout
        datesTableView.register(UINib(nibName: "ATCDatedChartDateRangeCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ATCDatedChartDateRangeCollectionViewCell")
        datesTableView.reloadData()
        delegate?.datedLineChartViewController(self, didSelect: selectedDate, titleLabel: titleLabel, chartView: chartView)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateList.dates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ATCDatedChartDateRangeCollectionViewCell", for: indexPath) as? ATCDatedChartDateRangeCollectionViewCell {
            cell.titleLabel.text = dateList.dates[indexPath.row].title
            cell.titleLabel.font = uiConfig.boldFont(size: 14)
            cell.titleLabel.textColor = uiConfig.mainTextColor

            cell.containerView.clipsToBounds = true
            cell.containerView.layer.cornerRadius = 5
            cell.containerView.backgroundColor = .clear

            if dateList.dates[indexPath.row].title == selectedDate.title {
                cell.containerView.backgroundColor = UIColor(hexString: "#617181")
                cell.titleLabel.textColor = uiConfig.mainThemeBackgroundColor
            } else {
                cell.titleLabel.textColor = uiConfig.mainTextColor
            }
            return cell
        }
        fatalError()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedDate = dateList.dates[indexPath.row]
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()

        datesTableView.reloadData()
        delegate?.datedLineChartViewController(self, didSelect: selectedDate, titleLabel: titleLabel, chartView: chartView)
    }
}


extension ATCDatedLineChartViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / CGFloat(dateList.dates.count), height: 30.0)
    }
}
