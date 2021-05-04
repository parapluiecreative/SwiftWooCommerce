//
//  ShoppingCartCollectionViewCell.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/7/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ShoppingCartCollectionViewCellDelegate: class {
    func shoppingCartCollectionViewCell(_ cell: ShoppingCartCollectionViewCell, didTapUp item: ATCShoppingCartItem)
    func shoppingCartCollectionViewCell(_ cell: ShoppingCartCollectionViewCell, didTapDown item: ATCShoppingCartItem)
    func shoppingCartCollectionViewCell(_ cell: ShoppingCartCollectionViewCell, didSelectColor color: String, for item: ATCShoppingCartItem)
    func shoppingCartCollectionViewCell(_ cell: ShoppingCartCollectionViewCell, didSelectSize size: String, for item: ATCShoppingCartItem)
}

class ShoppingCartCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var colorLabel: UILabel!
    @IBOutlet var colorSelectorView: UIView!
    @IBOutlet var quantityContainerView: UIView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var sizeSelectorView: UIView!
    @IBOutlet var upButton: UIButton!
    @IBOutlet var downButton: UIButton!
    @IBOutlet var quantityLabel: UILabel!

    var colorViewController: ColorSelectorViewController? = nil
    var sizeViewController: SizeSelectorViewController? = nil

    var item: ATCShoppingCartItem?
    weak var delegate: ShoppingCartCollectionViewCellDelegate?

    func configure(item: ATCShoppingCartItem) {
        self.item = item
        upButton.addTarget(self, action: #selector(didTapUpButton), for: .touchUpInside)
        downButton.addTarget(self, action: #selector(didTapDownButton), for: .touchUpInside)
    }

    func configureColorSelector(uiConfig: ATCUIGenericConfigurationProtocol,
                                hostViewController: UIViewController?) {
        guard let item = item else { return }
        if let colorVC = colorViewController {
            hostViewController?.removeChildViewController(colorVC)
        }

        colorViewController = ColorSelectorViewController(colors: item.product.cartColors, uiConfig: uiConfig, cellType: .small)
        colorViewController?.genericDataSource = ATCGenericLocalHeteroDataSource(items: item.product.cartColors.map({ATCColor(hexString: $0)}))
        colorViewController?.delegate = self
        colorViewController?.view.frame = colorSelectorView.bounds
        if let selectedColor = item.selectedColor {
            colorViewController?.updateSelectedColor(selectedColor)
        }

        hostViewController?.addChildViewControllerWithView(colorViewController!, toView: colorSelectorView)
    }

    func configureSizeSelector(uiConfig: ATCUIGenericConfigurationProtocol,
                                hostViewController: UIViewController?) {
        guard let item = item else { return }
        if let sizeVC = sizeViewController {
            hostViewController?.removeChildViewController(sizeVC)
        }

        sizeViewController = SizeSelectorViewController(sizes: item.product.cartSizes, uiConfig: uiConfig, cellType: .small)
        sizeViewController?.genericDataSource = ATCGenericLocalHeteroDataSource(items: item.product.cartSizes.map({ATCSize(title: $0)}))
        sizeViewController?.delegate = self
        sizeViewController?.view.frame = sizeSelectorView.bounds
        if let selectedSize = item.selectedSize {
            sizeViewController?.updateSelectedSize(selectedSize)
        }

        hostViewController?.addChildViewControllerWithView(sizeViewController!, toView: sizeSelectorView)
    }

    @objc private func didTapUpButton() {
        guard let item = item else { return }
        delegate?.shoppingCartCollectionViewCell(self, didTapUp: item)
    }

    @objc private func didTapDownButton() {
        guard let item = item else { return }
        delegate?.shoppingCartCollectionViewCell(self, didTapDown: item)
    }
}


extension ShoppingCartCollectionViewCell: ColorSelectorViewControllerDelegate {
    /// MARK:- ColorSelectorViewControllerDelegate
    func colorSelectorViewController(_ colorSelectorViewController: ColorSelectorViewController, didSelect color: String) {
        guard let item = item else { return }
        self.delegate?.shoppingCartCollectionViewCell(self, didSelectColor: color, for: item)
    }
}

extension ShoppingCartCollectionViewCell: SizeSelectorViewControllerDelegate {
    func sizeSelectorViewController(_ sizeSelectorViewController: SizeSelectorViewController, didSelect size: String) {
        guard let item = item else { return }
        self.delegate?.shoppingCartCollectionViewCell(self, didSelectSize: size, for: item)
    }
}
