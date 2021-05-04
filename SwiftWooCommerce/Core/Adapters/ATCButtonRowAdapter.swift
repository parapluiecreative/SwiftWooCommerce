//
//  ATCTextRowAdapter.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCButtonRowAdapter: ATCGenericCollectionRowAdapter {
    
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCButtonProtocol, let cell = cell as? ATCButtonCollectionViewCell else { return }
        cell.configure(viewModel: viewModel, uiConfig: uiConfig)
        cell.setNeedsLayout()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCButtonCollectionViewCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCButtonProtocol else { return .zero }
        let screenSize = UIScreen.main.bounds
        return CGSize(width: screenSize.width, height: viewModel.buttonHeight)
    }
}
