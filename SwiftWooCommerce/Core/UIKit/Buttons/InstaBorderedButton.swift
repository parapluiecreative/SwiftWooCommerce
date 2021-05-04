//
//  InstaTextButton.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/2/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class InstaBorderedButton: UIButton {
    func configure(tintColor: UIColor = .blue,
                   font: UIFont,
                   bgColor: UIColor = .white,
                   borderColor: UIColor,
                   borderWidth: CGFloat = 1,
                   cornerRadius: CGFloat) {
        self.backgroundColor = bgColor
        self.tintColor = tintColor
        self.titleLabel?.font = font
        self.titleLabel?.textColor = tintColor
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
