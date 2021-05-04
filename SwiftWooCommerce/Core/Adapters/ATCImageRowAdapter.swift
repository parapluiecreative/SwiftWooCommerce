//
//  ATCImageRowAdapter.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit
import AVKit

protocol ATCImageRowAdapterDelegate: class {
    func imageRowAdapter(_ adapter: ATCImageRowAdapter, didLoad image: UIImage)
}

class ATCImageRowAdapter: ATCGenericCollectionRowAdapter {

    let cellHeight: CGFloat?
    let cellWidth: CGFloat?
    let contentMode: UIView.ContentMode
    let cornerRadius: CGFloat?
    let size: ((CGRect) -> CGSize)?
    let tintColor: UIColor?
    let bgColor: UIColor?

    weak var delegate: ATCImageRowAdapterDelegate?

    init(cellHeight: CGFloat? = nil,
         cellWidth: CGFloat? = nil,
         contentMode: UIView.ContentMode = .scaleAspectFill,
         cornerRadius: CGFloat? = nil,
         size: ((CGRect) -> CGSize)? = nil,
         tintColor: UIColor? = nil,
         bgColor: UIColor? = nil) {
        self.cellHeight = cellHeight
        self.cellWidth = cellWidth
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.size = size
        self.tintColor = tintColor
        self.bgColor = bgColor
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCImage, let cell = cell as? ATCImageCollectionViewCell else { return }
        cell.atcImageView.contentMode = contentMode
        cell.atcImageView.clipsToBounds = true
        cell.clipsToBounds = true

        if let url = viewModel.urlString {
            cell.atcImageView.kf.setImage(with: URL(string: url),
                                          placeholder: nil,
                                          options: nil,
                                          progressBlock: nil) {[weak self] result in
                                            guard let `self` = self else { return }
                                            switch result {
                                            case .success(let value):
                                                self.delegate?.imageRowAdapter(self, didLoad: value.image)
                                            case .failure( _): break
                                            }

            }
        } else {
            cell.atcImageView.image = viewModel.localImage
        }
        if let cornerRadius = cornerRadius {
            cell.atcImageView.layer.cornerRadius = cornerRadius
        }
        if viewModel.isActionable {
            cell.atcImageView.contentMode = .center
            cell.atcImageView.tintColor = tintColor
            cell.atcImageView.backgroundColor = bgColor
        }
        if viewModel.isVideoPreview {
            cell.atcVideoPreviewIcon.isHidden = false
            if let videoUrlString = viewModel.videoUrlString, let url = URL(string: videoUrlString) {
                let avPlayer = AVPlayer(url: url)
                cell.atcVideoPlayerView.playerLayer?.player = avPlayer
            }
        } else {
            cell.atcVideoPreviewIcon.isHidden = true
            cell.atcVideoPlayerView.playerLayer?.player = nil
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCImageCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let _ = object as? ATCImage else { return .zero }
        if let size = size {
            return size(containerBounds)
        }
        var height = containerBounds.height
        if let cellHeight = cellHeight {
            height = cellHeight
        }
        var w = containerBounds.width
        if let cellW = cellWidth {
            w = cellW
        }
        return CGSize(width: w, height: height)
    }
}
