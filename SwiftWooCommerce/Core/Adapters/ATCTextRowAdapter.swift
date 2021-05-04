//
//  ATCTextRowAdapter.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCTextRowAdapter: ATCGenericCollectionRowAdapter {
    var font: UIFont
    var textColor: UIColor
    var staticHeight: CGFloat?
    var bgColor: UIColor?
    var alignment: NSTextAlignment
    
    init(font: UIFont,
         textColor: UIColor,
         staticHeight: CGFloat? = nil,
         bgColor: UIColor? = nil,
         alignment: NSTextAlignment = .left) {
        self.font = font
        self.textColor = textColor
        self.staticHeight = staticHeight
        self.bgColor = bgColor
        self.alignment = alignment
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCTextProtocol, let cell = cell as? ATCTextCollectionViewCell else { return }
        if let viewModel = object as? ATCTextWithStyleProtocol {
            cell.label.font = viewModel.textFont
            cell.label.textColor = viewModel.textColor
        } else {
            cell.label.font = font
            cell.label.textColor = textColor
        }
        cell.label.text = viewModel.text
        cell.label.textAlignment = alignment
        
        if let bgColor = bgColor {
            cell.backgroundColor = bgColor
        }
        cell.label.setNeedsLayout()

        if let accessoryText = viewModel.accessoryText {
            cell.accessoryLabel.text = accessoryText
            cell.accessoryLabel.font = font.withSize(14.0)
            cell.accessoryLabel.textColor = UIColor(hexString: "#a6a6a6")
            cell.accessoryLabel.isHidden = false
        } else {
            cell.accessoryLabel.isHidden = true
        }
        cell.setNeedsLayout()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCTextCollectionViewCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard let viewModel = object as? ATCTextProtocol else { return .zero }
        let width = containerBounds.width
        if let staticHeight = staticHeight {
            return CGSize(width: width, height: staticHeight)
        }
        let height = viewModel.text.height(withConstrainedWidth: width, font: self.font)
        return CGSize(width: width, height: height + font.lineHeight)
    }
}
