//
//  ATCGridCollectionViewCell.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/9/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCButtonProtocol {
    var buttonFont: UIFont {get}
    var buttonTextColor: UIColor {get}
    var buttonBackgroundColor: UIColor {get}
    var buttonHeight: CGFloat {get}
    var cornerRadius: CGFloat {get}
    var padding: CGFloat {get}
    var callToAction: String? {get}
    var callToActionBlock: (() -> Void)? {get}
}

class ATCButton: ATCGenericBaseModel, ATCButtonProtocol {
    var description: String {
        return callToAction ?? ""
    }
    var buttonFont: UIFont
    var buttonTextColor: UIColor
    var buttonHeight: CGFloat
    var buttonBackgroundColor: UIColor
    
    var cornerRadius: CGFloat
    var padding: CGFloat

    let callToAction: String?
    var callToActionBlock: (() -> Void)?

    init(buttonFont: UIFont,
         buttonTextColor: UIColor,
         buttonHeight: CGFloat,
         buttonBackgroundColor: UIColor,
         cornerRadius: CGFloat = 0,
         padding: CGFloat = 20,
         callToAction: String? = nil,
         callToActionBlock: (() -> Void)? = nil) {
        self.buttonFont = buttonFont
        self.buttonTextColor = buttonTextColor
        self.buttonHeight = buttonHeight
        self.buttonBackgroundColor = buttonBackgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.callToAction = callToAction
        self.callToActionBlock = callToActionBlock
    }

    required init(jsonDict: [String : Any]) {
        fatalError("init(jsonDict:) has not been implemented")
    }
}

class ATCButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet var callToActionButton: UIButton!
    @IBOutlet weak var buttonLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var buttonTrailingCons: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!

    private var viewModel: ATCButtonProtocol?

    func configure(viewModel: ATCButtonProtocol?, uiConfig: ATCUIGenericConfigurationProtocol) {
        if let viewModel = viewModel {
            self.viewModel = viewModel
            callToActionButton.titleLabel?.font = viewModel.buttonFont
            callToActionButton.setTitleColor(viewModel.buttonTextColor, for: .normal)
            callToActionButton.setTitle(viewModel.callToAction, for: .normal)
            callToActionButton.backgroundColor = viewModel.buttonBackgroundColor
            callToActionButton.layer.cornerRadius = viewModel.cornerRadius
            buttonLeadingCons.constant = viewModel.padding
            buttonTrailingCons.constant = viewModel.padding
        }
        callToActionButton.addTarget(self, action: #selector(didTapCallToActionButton) , for: .touchUpInside)
        self.setNeedsLayout()
    }

    @objc func didTapCallToActionButton() {
        if let block = viewModel?.callToActionBlock {
            block()
        }
    }
}
