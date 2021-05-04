//
//  ATCSocialNetworkPostImageViewerCellAdapter.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 16/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCMediaViewerImageCellAdapterDelegate: class {
    func dismiss()
}

class ATCMediaViewerImageCellAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    var delegate: ATCMediaViewerImageCellAdapterDelegate? = nil
    
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let image = object as? ATCImage, let cell = cell as? ATCMediaViewerImageCell {
            cell.delegate = self
            if let imageURL = image.urlString {
                cell.postImageView.kf.setImage(with: URL(string: imageURL))
            }else {
                print("Image not found")
            }
            
            cell.setNeedsLayout()
        }
    }
    
    
    func cellClass() -> UICollectionViewCell.Type {
        return ATCMediaViewerImageCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard object is ATCImage else { return .zero }
        let cellHeight: CGFloat = UIScreen.main.bounds.height
        let cellWidth = UIScreen.main.bounds.width
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}

extension ATCMediaViewerImageCellAdapter : ATCSwipeToDismissImageViewDelegate {
    func dismissImageViewer() {
        self.delegate?.dismiss()
    }
}
