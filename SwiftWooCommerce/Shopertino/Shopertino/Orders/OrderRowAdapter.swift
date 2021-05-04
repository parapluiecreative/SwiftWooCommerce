//
//  OrderRowAdapter.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/20/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class OrderRowAdapter: ATCGenericCollectionRowAdapter {

    weak var parentVC: UIViewController?
    weak var cartVC: ShoppingCartViewController?

    var VCs = [String: ATCGenericCollectionViewController]()
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(parentVC: UIViewController,
         uiConfig: ATCUIGenericConfigurationProtocol,
         cartVC: ShoppingCartViewController) {
        self.parentVC = parentVC
        self.uiConfig = uiConfig
        self.cartVC = cartVC
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let order = object as? ATCOrder, let cell = cell as? OrderCollectionViewCell else { return }
        cell.delegate = self
        cell.configure(viewModel: order)

        cell.orderImageView.kf.setImage(with: order.headerImageURL())
        cell.orderImageView.contentMode = .scaleAspectFill
        cell.orderImageView.clipsToBounds = true

        cell.headerBackgroundView.backgroundColor = uiConfig.colorGray0
        cell.footerBackgroundView.backgroundColor = uiConfig.mainThemeBackgroundColor

        cell.headerBackgroundView.layer.cornerRadius = 8

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        cell.dateLabel.text = "Ordered on ".localizedInApp + dateFormatter.string(from: order.createdAt)
        cell.dateLabel.font = uiConfig.regularFont(size: 12)
        cell.dateLabel.textColor = uiConfig.mainThemeBackgroundColor
        cell.dateLabel.alpha = 0.8

        cell.statusLabel.text = order.status
        cell.statusLabel.font = uiConfig.boldFont(size: 16)
        cell.statusLabel.textColor = uiConfig.mainThemeBackgroundColor
        cell.statusLabel.alpha = 0.9

        if let totalPrice = order.totalPrice() {
            cell.totalPriceLabel.text = "Total: $".localizedInApp +  totalPrice.twoDecimalsString()
        } else {
            cell.totalPriceLabel.text = ""
        }
        cell.totalPriceLabel.font = uiConfig.boldFont(size: 14)
        cell.totalPriceLabel.textColor = uiConfig.mainTextColor

        cell.placeOrderButton.setTitle("REORDER".localizedInApp, for: .normal)
        cell.placeOrderButton.backgroundColor = uiConfig.mainThemeForegroundColor.darkModed
        cell.placeOrderButton.setTitleColor(.white, for: .normal)
        cell.placeOrderButton.layer.cornerRadius = 3
        cell.placeOrderButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(50)
        }
        cell.placeOrderButton.titleLabel?.font = uiConfig.boldFont(size: 14)

        if let containerView = cell.collectionContainerView, let items = order.shoppingCart?.distinctProductItems() {
            containerView.subviews.forEach({ (view) in
                view.removeFromSuperview()
            })
            if VCs[order.id] == nil {
                let dataSource = ATCGenericLocalDataSource(items: items)
                let emptyViewModel = CPKEmptyViewModel(image: nil, title: "No Orders".localizedInApp, description: "No orders yet.".localizedInApp, callToAction: nil)
                let config = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                             pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                             collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                             collectionViewLayout: ATCCollectionViewFlowLayout(),
                                                                             collectionPagingEnabled: false,
                                                                             hideScrollIndicators: false,
                                                                             hidesNavigationBar: false,
                                                                             headerNibName: nil,
                                                                             scrollEnabled: true,
                                                                             uiConfig: uiConfig,
                                                                             emptyViewModel: emptyViewModel)
                let vc = ATCGenericCollectionViewController(configuration: config)
                vc.genericDataSource = dataSource
                vc.use(adapter: OrderCartItemRowAdapter(uiConfig: uiConfig), for: "ATCShoppingCartItem")
                VCs[order.id] = vc
            }
            let vc = VCs[order.id]!
            vc.view.frame = containerView.bounds
            containerView.addSubview(vc.view)
            cell.setNeedsLayout()
        }

        cell.containerView.clipsToBounds = true

        cell.containerView.layer.masksToBounds = false
        cell.containerView.layer.cornerRadius = 8
        cell.containerView.layer.shadowColor = UIColor.darkModeColor(hexString: "#333333").cgColor
        cell.containerView.layer.shadowOpacity = 0.4
        cell.containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.containerView.layer.shadowRadius = 3
        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    func cellClass() -> UICollectionViewCell.Type {
        return OrderCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        var h: CGFloat = 95 + 50 + 20 + 30 + 10
        if let order = object as? ATCOrder {
            h += CGFloat(order.totalItems()) * (80 + 5)
        }
        return CGSize(width: containerBounds.width,
                      height: h)
    }
}

extension OrderRowAdapter : OrderCollectionViewCellDelegate {
    func cell(_ cell: OrderCollectionViewCell, didTapReorderOrder order: ATCOrder) {
        if let cart = order.shoppingCart {
            cartVC?.cartManager.ingest(cart, vendorID: nil)
            if let cartVC = cartVC {
                self.parentVC?.navigationController?.pushViewController(cartVC, animated: true)
            }
        }
    }
}
