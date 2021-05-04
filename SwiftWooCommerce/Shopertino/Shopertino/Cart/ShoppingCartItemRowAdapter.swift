//
//  ShoppingCartItemRowAdapter.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/7/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ShoppingCartItemRowAdapterDelegate: class {
    func shoppingCartRowAdapter(_ adapter: ShoppingCartItemRowAdapter, didIncreaseQuantityFor item: ATCShoppingCartItem)
    func shoppingCartRowAdapter(_ adapter: ShoppingCartItemRowAdapter, didDecreaseQuantityFor item: ATCShoppingCartItem)
    func shoppingCartRowAdapter(_ adapter: ShoppingCartItemRowAdapter, didSelectColor color: String, for item: ATCShoppingCartItem)
    func shoppingCartRowAdapter(_ adapter: ShoppingCartItemRowAdapter, didSelectSize size: String, for item: ATCShoppingCartItem)
}

class ShoppingCartItemRowAdapter: ATCGenericCollectionRowAdapter, ShoppingCartCollectionViewCellDelegate {
    private let uiConfig: ATCUIGenericConfigurationProtocol
    private weak var hostViewController: UIViewController?
    weak var delegate: ShoppingCartItemRowAdapterDelegate?

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         hostViewController: UIViewController) {
        self.uiConfig = uiConfig
        self.hostViewController = hostViewController
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let item = object as? ATCShoppingCartItem, let cell = cell as? ShoppingCartCollectionViewCell else { return }
        cell.configure(item: item)
        cell.delegate = self

        cell.imageView.kf.setImage(with: URL(string: item.product.cartImageURLString))
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.layer.masksToBounds = true
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.cornerRadius = 8

        cell.titleLabel.text = item.product.cartTitle
        cell.titleLabel.textColor = uiConfig.mainTextColor
        cell.titleLabel.font = uiConfig.regularFont(size: 14)
        cell.containerView.layer.cornerRadius = 10
        cell.clipsToBounds = true

        cell.colorLabel.text = "Color".localizedInApp
        cell.colorLabel.textColor = uiConfig.mainTextColor
        cell.colorLabel.font = uiConfig.regularFont(size: 12)

        if item.product.cartColors.count > 0 {
            cell.configureColorSelector(uiConfig: uiConfig, hostViewController: hostViewController)
            cell.colorLabel.isHidden = false
            cell.colorSelectorView.isHidden = false
        } else {
            if let colorVC = cell.colorViewController {
                self.hostViewController?.removeChildViewController(colorVC)
            }
            cell.colorLabel.isHidden = true
            cell.colorSelectorView.isHidden = true
        }

        if item.product.cartSizes.count > 0 {
            cell.configureSizeSelector(uiConfig: uiConfig, hostViewController: hostViewController)
            cell.sizeLabel.isHidden = false
            cell.sizeSelectorView.isHidden = false
        } else {
            if let sizeVC = cell.sizeViewController {
                self.hostViewController?.removeChildViewController(sizeVC)
            }
            cell.sizeLabel.isHidden = true
            cell.sizeSelectorView.isHidden = true
        }

        cell.sizeLabel.text = "Size".localizedInApp
        cell.sizeLabel.textColor = uiConfig.mainTextColor
        cell.sizeLabel.font = uiConfig.regularFont(size: 12)

        cell.priceLabel.text = "$" + (item.product.cartPrice * Double(item.quantity)).twoDecimalsString()
        cell.priceLabel.textColor = uiConfig.mainTextColor
        cell.priceLabel.font = uiConfig.boldFont(size: 16)

        cell.quantityLabel.text = String(item.quantity)
        cell.quantityLabel.textColor = uiConfig.mainThemeForegroundColor
        cell.quantityLabel.font = uiConfig.boldFont(size: 16)

        cell.upButton.configure(color: UIColor(hexString: "#DBDBDE"),
                            font: uiConfig.boldFont(size: 20),
                            cornerRadius: 6,
                            borderColor: UIColor(hexString: "#DBDBDE"),
                            backgroundColor: uiConfig.mainThemeBackgroundColor,
                            borderWidth: 0.5)
        cell.upButton.setTitle("+", for: .normal)

        cell.downButton.configure(color: UIColor(hexString: "#DBDBDE"),
                                font: uiConfig.boldFont(size: 20),
                                cornerRadius: 6,
                                borderColor: UIColor(hexString: "#DBDBDE"),
                                backgroundColor: uiConfig.mainThemeBackgroundColor,
                                borderWidth: 0.5)
        cell.downButton.setTitle("-", for: .normal)

        cell.delegate = self
        cell.containerView.dropShadow()
        cell.backgroundColor = UIColor.darkModeColor(hexString: "#fafafa")
        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cell.quantityContainerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cell.colorSelectorView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cell.sizeSelectorView.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ShoppingCartCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        return CGSize(width: containerBounds.width, height: 200)
    }

    /// MARK:- ShoppingCartCollectionViewCellDelegate
    func shoppingCartCollectionViewCell(_ cell: ShoppingCartCollectionViewCell, didTapUp item: ATCShoppingCartItem) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        delegate?.shoppingCartRowAdapter(self, didIncreaseQuantityFor: item)
    }

    func shoppingCartCollectionViewCell(_ cell: ShoppingCartCollectionViewCell, didTapDown item: ATCShoppingCartItem) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        delegate?.shoppingCartRowAdapter(self, didDecreaseQuantityFor: item)
    }

    func shoppingCartCollectionViewCell(_ cell: ShoppingCartCollectionViewCell, didSelectColor color: String, for item: ATCShoppingCartItem) {
        delegate?.shoppingCartRowAdapter(self, didSelectColor: color, for: item)
    }

    func shoppingCartCollectionViewCell(_ cell: ShoppingCartCollectionViewCell, didSelectSize size: String, for item: ATCShoppingCartItem) {
        delegate?.shoppingCartRowAdapter(self, didSelectSize: size, for: item)
    }
}
