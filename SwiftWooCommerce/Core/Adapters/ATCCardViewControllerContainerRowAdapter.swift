//
//  ATCCardViewControllerContainerRowAdapter.swift
//  FinanceApp
//
//  Created by Florian Marcu on 3/16/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCCardViewControllerContainerRowAdapter: ATCGenericCollectionRowAdapter {
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCViewControllerContainerViewModel, let cell = cell as? ATCCardViewControllerContainerCollectionViewCell else { return }
        cell.configure(viewModel: viewModel)
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCCardViewControllerContainerCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCViewControllerContainerViewModel else { return .zero }
        var height: CGFloat
        if let cellHeight = viewModel.cellHeight {
            height = cellHeight
        } else if let collectionVC = viewModel.viewController as? ATCGenericCollectionViewController,
            let dataSource = collectionVC.genericDataSource,
            let subcellHeight = viewModel.subcellHeight {
            height = CGFloat(dataSource.numberOfObjects()) * subcellHeight
        } else {
            fatalError("Please provide a mechanism to compute the cell height")
        }
        return CGSize(width: containerBounds.width, height: height)
    }
}
