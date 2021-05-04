//
//  BadgedCountLabel.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 8/31/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCBadgedCountLabel: UILabel {

    public var count: Int = 0 {
        didSet {
            self.text = count.description
            updateAppearance()
        }
    }

    public var rounded: Bool = true {
        didSet { updateCornerRadius() }
    }

    public var showsOnEmptyCount: Bool = false {
        didSet { updateAppearance() }
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

        guard rounded else { return }
        updateCornerRadius()
    }

    private func commonInit() {
        backgroundColor = UIColor(hexString: "#fb898e")
        textColor = .white
        layer.masksToBounds = true
        textAlignment = .center
    }

    private func updateCornerRadius() {
        layer.cornerRadius = bounds.height / 2
    }

    private func updateAppearance() {
        isHidden = !showsOnEmptyCount ? count == 0 : false
    }
}
