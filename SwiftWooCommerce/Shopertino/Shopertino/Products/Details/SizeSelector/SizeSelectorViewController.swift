//
//  SizeSelectorViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCSize: ATCGenericBaseModel {
    var description: String {
        return title
    }

    var title: String
    required init(jsonDict: [String: Any]) {
        fatalError()
    }

    init(title: String) {
        self.title = title
    }
}

class ATCSizeRowAdapter: ATCGenericCollectionRowAdapter {

    private let uiConfig: ATCUIGenericConfigurationProtocol
    var selectedSize: String?
    let cellType: SizeSelectorCellType

    init(uiConfig: ATCUIGenericConfigurationProtocol, cellType: SizeSelectorCellType) {
        self.cellType = cellType
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let size = object as? ATCSize, let cell = cell as? SizeSelectorCollectionViewCell else { return }

        cell.sizeLabel.text = size.title
        cell.sizeLabel.font = uiConfig.regularFont(size: 14)

        cell.containerView.layer.cornerRadius = 4

        if selectedSize == size.title {
            cell.containerView.layer.borderWidth = 0.5
            cell.containerView.backgroundColor = uiConfig.mainThemeForegroundColor
            cell.sizeLabel.textColor = uiConfig.mainThemeBackgroundColor

            cell.containerView.layer.borderColor = UIColor(hexString: "#DBDBDE").cgColor
        } else {
            cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
            cell.sizeLabel.textColor = uiConfig.mainTextColor
            cell.containerView.layer.borderColor = nil
            cell.containerView.layer.borderWidth = 0
        }
        cell.clipsToBounds = true
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return SizeSelectorCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        if cellType == .large {
            return CGSize(width: 25, height: 25)
        }
        return CGSize(width: 20, height: 20)
    }
}

protocol SizeSelectorViewControllerDelegate: class {
    func sizeSelectorViewController(_ sizeSelectorViewController: SizeSelectorViewController, didSelect size: String)
}

enum SizeSelectorCellType {
    case small
    case large
}

class SizeSelectorViewController: ATCGenericCollectionViewController {
    let rowAdapter: ATCSizeRowAdapter

    weak var delegate: SizeSelectorViewControllerDelegate?

    init(sizes: [String],
         uiConfig: ATCUIGenericConfigurationProtocol,
         cellType: SizeSelectorCellType) {
        self.rowAdapter = ATCSizeRowAdapter(uiConfig: uiConfig, cellType: cellType)
        if sizes.count > 0 {
            self.rowAdapter.selectedSize = sizes[0]
        }
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewBackgroundColor: .clear,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: false,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        super.init(configuration: configuration)
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: sizes.map({ATCSize(title: $0)}))
        self.use(adapter: rowAdapter, for: "ATCSize")
        self.selectionBlock = {[weak self] (navigationController, object, index) in
            guard let `self` = self else { return }
            if let size = object as? ATCSize {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                self.rowAdapter.selectedSize = size.title
                self.delegate?.sizeSelectorViewController(self, didSelect: size.title)
                self.genericDataSource?.loadFirst()
            }
        }
    }

    func updateSelectedSize(_ selectedSize: String) {
        self.rowAdapter.selectedSize = selectedSize
        self.genericDataSource?.loadFirst()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
