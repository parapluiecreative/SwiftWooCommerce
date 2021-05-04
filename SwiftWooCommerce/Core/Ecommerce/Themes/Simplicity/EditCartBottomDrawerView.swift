//
//  EditCartBottomDrawerView.swift
//  MultiVendorApp
//
//  Created by Florian Marcu on 12/1/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol EditCartBottomDrawerViewDelegate: class {
    func editCartViewDidTapRemoveButton(_ editView: EditCartBottomDrawerView)
    func editCartView(_ editView: EditCartBottomDrawerView, didTapUpdateWith quantity: Int)
}

class EditCartBottomDrawerView: UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepperier: Stepperier!
    @IBOutlet weak var editCartButton: UIButton!
    @IBOutlet weak var removeFromCartButton: UIButton!

    weak var delegate: EditCartBottomDrawerViewDelegate?
    let viewModel: ATCShoppingCartItem

    init(shoppingItem: ATCShoppingCartItem,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        self.viewModel = shoppingItem
        super.init(frame: .zero)
        commonInit(uiConfig: uiConfig)
        titleLabel.text = shoppingItem.product.cartTitle
        stepperier.value = shoppingItem.quantity
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit(uiConfig: ATCUIGenericConfigurationProtocol) {
        Bundle.main.loadNibNamed("EditCartBottomDrawerView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        titleLabel.font = uiConfig.regularFont(size: 18)
        titleLabel.textColor = uiConfig.mainTextColor

        editCartButton.setTitle("Update item".localizedEcommerce, for: .normal)
        editCartButton.addTarget(self, action: #selector(didTapUpdateButton), for: .touchUpInside)
        editCartButton.configure(color: .white,
                                 font: uiConfig.regularFont(size: 14),
                                 cornerRadius: 5,
                                 borderColor: nil,
                                 backgroundColor: uiConfig.mainThemeForegroundColor,
                                 borderWidth: nil)

        removeFromCartButton.setTitle("Remove from cart".localizedEcommerce, for: .normal)
        removeFromCartButton.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
        removeFromCartButton.configure(color: UIColor.red,
                                       font: uiConfig.regularFont(size: 14),
                                       cornerRadius: 0,
                                       borderColor: nil,
                                       backgroundColor: UIColor.clear,
                                       borderWidth: nil)

        stepperier.operationSymbolsColor = UIColor.black.darkModed
        stepperier.valueBackgroundColor = UIColor.white.darkModed
        stepperier.value = 1
        stepperier.tintColor = UIColor.black.darkModed

        stepperier.layer.borderWidth = 1
        stepperier.layer.cornerRadius = 10
        stepperier.layer.borderColor = (UIColor(hexString: "#cccccc").darkModed).cgColor
        stepperier.font = uiConfig.regularFont(size: 16)
        containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    @objc func didTapRemoveButton() {
        self.delegate?.editCartViewDidTapRemoveButton(self)
    }

    @objc func didTapUpdateButton() {
        self.delegate?.editCartView(self, didTapUpdateWith: stepperier.value)
    }
}
