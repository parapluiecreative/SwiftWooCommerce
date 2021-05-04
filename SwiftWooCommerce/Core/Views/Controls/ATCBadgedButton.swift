//
//  BadgedButton.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 8/31/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let badgedCountLabelHPadding: CGFloat = 6
    static let badgedCountLabelVPadding: CGFloat = 2
    static let badgedCountLabelYOffset: CGFloat = 3
    static let badgedCountLabelFontSize: CGFloat = 12
}

class ATCBadgedButton: UIButton {

    private let badgedCountLabel = ATCBadgedCountLabel()

    var count: Int = 0 {
        didSet {
            badgedCountLabel.isHidden = (count == 0)
            badgedCountLabel.count = count
            self.setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = badgedCountLabel.sizeThatFits(bounds.size)
        let badgedCountLabelSize = CGSize(width: size.width + 2 * Constants.badgedCountLabelHPadding, height: size.height + 2 * Constants.badgedCountLabelVPadding)
        let badgedCountLabelOrigin = CGPoint(x: bounds.maxX - badgedCountLabelSize.width / 2, y: -Constants.badgedCountLabelYOffset)
        badgedCountLabel.frame = CGRect(origin: badgedCountLabelOrigin, size: badgedCountLabelSize)
    }

    private func commonInit() {
        addSubview(badgedCountLabel)
        badgedCountLabel.isHidden = true
        if let fontName = self.titleLabel?.font.fontName {
            badgedCountLabel.font = UIFont(name: fontName, size: Constants.badgedCountLabelFontSize)
        }
        badgedCountLabel.isUserInteractionEnabled = false
        //self.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
}
