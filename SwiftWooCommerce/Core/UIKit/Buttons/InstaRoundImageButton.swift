//
//  InstaRoundImageButton.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class InstaRoundImageButton: UIButton {

    class func newButton() -> InstaRoundImageButton {
        let button = InstaRoundImageButton.init(type: .system)
        button.configInit()
        return button
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width / 2.0
    }

    func configure(image: UIImage = UIImage.localImage("share-icon", template: true),
                   tintColor: UIColor = .blue,
                   bgColor: UIColor = .white) {
        self.setImage(image, for: .normal)
        self.backgroundColor = bgColor
        self.tintColor = tintColor
        self.setTitle(nil, for: .normal)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    fileprivate func configInit() {
        self.backgroundColor = .white

        layer.masksToBounds = false
        layer.shadowColor = UIColor(hexString: "#bbbbbb").cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = 1
    }
}
