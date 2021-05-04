//
//  ColorSelectorViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/6/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCColor: ATCGenericBaseModel {
    var description: String {
        return hexString
    }

    var hexString: String
    required init(jsonDict: [String: Any]) {
        fatalError()
    }

    init(hexString: String) {
        self.hexString = hexString
    }
}

class ATCColorRowAdapter: ATCGenericCollectionRowAdapter {

    private let uiConfig: ATCUIGenericConfigurationProtocol
    var selectedColor: String?
    let cellType: ColorSelectorCellType

    init(uiConfig: ATCUIGenericConfigurationProtocol, cellType: ColorSelectorCellType) {
        self.cellType = cellType
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let color = object as? ATCColor, let cell = cell as? ColorSelectorCollectionViewCell else { return }
        let imageView = cell.imageView!
        if selectedColor == color.hexString {
            imageView.isHidden = false
            imageView.image = UIImage.localImage("check-simple-icon").image(resizedTo: CGSize(width: 18, height: 18))!
            if color.hexString.lowercased() == "#ffffff" {
                imageView.tintColor = .black
            } else {
                imageView.tintColor = .white
            }
            imageView.contentMode = .center
        } else {
            imageView.isHidden = true
        }
        imageView.setNeedsLayout()
        imageView.layoutIfNeeded()

        cell.containerView.backgroundColor = UIColor(hexString: color.hexString, alpha: 1)
        cell.containerView.layer.cornerRadius = 4
        cell.containerView.layer.borderWidth = 0.5
        cell.containerView.layer.borderColor = UIColor(hexString: "#DBDBDE").cgColor
        cell.clipsToBounds = true
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ColorSelectorCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        if cellType == .large {
            return CGSize(width: 25, height: 25)
        }
        return CGSize(width: 20, height: 20)
    }
}

protocol ColorSelectorViewControllerDelegate: class {
    func colorSelectorViewController(_ colorSelectorViewController: ColorSelectorViewController, didSelect color: String)
}

enum ColorSelectorCellType {
    case small
    case large
}

class ColorSelectorViewController: ATCGenericCollectionViewController {
    let rowAdapter: ATCColorRowAdapter

    weak var delegate: ColorSelectorViewControllerDelegate?

    init(colors: [String],
         uiConfig: ATCUIGenericConfigurationProtocol,
         cellType: ColorSelectorCellType) {
        self.rowAdapter = ATCColorRowAdapter(uiConfig: uiConfig, cellType: cellType)
        if colors.count > 0 {
            self.rowAdapter.selectedColor = colors[0]
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
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: colors.map({ATCColor(hexString: $0)}))
        self.use(adapter: rowAdapter, for: "ATCColor")
        self.selectionBlock = {[weak self] (navigationController, object, index) in
            guard let `self` = self else { return }
            if let color = object as? ATCColor {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                self.rowAdapter.selectedColor = color.hexString
                self.delegate?.colorSelectorViewController(self, didSelect: color.hexString)
                self.genericDataSource?.loadFirst()
            }
        }
    }

    func updateSelectedColor(_ selectedColor: String) {
        self.rowAdapter.selectedColor = selectedColor
        self.genericDataSource?.loadFirst()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
