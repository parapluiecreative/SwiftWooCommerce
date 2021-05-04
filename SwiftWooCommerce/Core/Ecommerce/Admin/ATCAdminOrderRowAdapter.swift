//
//  ATCAdminOrderRowAdapter.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/27/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import UIKit

class ATCAdminOrderRowAdapter: ATCGenericCollectionRowAdapter {

    weak var parentVC: ATCGenericCollectionViewController?
    weak var selectedCell: ATCAdminOrderCollectionViewCell?
    weak var bottomSelectVC: UIViewController?

    var VCs = [String: ATCGenericCollectionViewController]()
    let uiConfig: ATCUIGenericConfigurationProtocol
    let dsProvider: ATCEcommerceDataSourceProvider
    private let uiEcommerceConfig: ATCUIConfigurationProtocol
    init(parentVC: ATCGenericCollectionViewController,
         uiConfig: ATCUIGenericConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider,
         uiEcommerceConfig: ATCUIConfigurationProtocol) {
        self.parentVC = parentVC
        self.uiConfig = uiConfig
        self.dsProvider = dsProvider
        self.uiEcommerceConfig = uiEcommerceConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let order = object as? ATCOrder, let cell = cell as? ATCAdminOrderCollectionViewCell else { return }
        cell.delegate = self
        cell.configure(viewModel: order)

        if let urlStr = order.customer?.profilePictureURL {
            cell.avatarImageView.kf.setImage(with: URL(string: urlStr))
        }
        cell.avatarImageView.contentMode = .scaleAspectFill
        cell.avatarImageView.clipsToBounds = true
        cell.avatarImageView.layer.cornerRadius = 35.0 / 2.0

        cell.customerNameLabel.text = order.customer?.fullName()
        cell.customerNameLabel.font = uiConfig.boldFont(size: 14)
        cell.customerNameLabel.textColor = uiConfig.mainTextColor

        cell.orderIDLabel.text = "Order #".localizedEcommerce + order.id
        cell.orderIDLabel.font = uiConfig.regularFont(size: 12)
        cell.orderIDLabel.textColor = uiConfig.mainSubtextColor

        cell.dateLabel.text = TimeFormatHelper.chatString(for: order.createdAt)
        cell.dateLabel.font = uiConfig.regularFont(size: 14)
        cell.dateLabel.textColor = uiConfig.mainSubtextColor

        if let address = order.address?.description {
            cell.addressLabel.text = "Address: ".localizedEcommerce + address
        }
        cell.addressLabel.font = uiConfig.regularFont(size: 12)
        cell.addressLabel.textColor = uiConfig.mainTextColor

        if let totalPrice = order.totalPrice() {
            cell.totalLabel.text =  "Total: $".localizedEcommerce + totalPrice.twoDecimalsString()
        } else {
            cell.totalLabel.text = ""
        }
        cell.totalLabel.font = uiConfig.regularFont(size: 16)

        cell.statusButton.setTitle(order.status.uppercased(), for: .normal)
        cell.statusButton.backgroundColor = uiConfig.mainThemeForegroundColor
        cell.statusButton.setTitleColor(.white, for: .normal)
        cell.statusButton.layer.cornerRadius = 3
        cell.statusButton.titleLabel?.font = uiConfig.regularFont(size: 12)

        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cell.containerView.layer.cornerRadius = 10
        cell.containerView.clipsToBounds = true
        cell.backgroundColor = .clear

        if let containerView = cell.collectionContainerView, let items = order.shoppingCart?.distinctProductItems() {
            containerView.subviews.forEach({ (view) in
                view.removeFromSuperview()
            })
            if VCs[order.id] == nil {
                let dataSource = ATCGenericLocalDataSource(items: items)
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
                                                                             emptyViewModel: nil)
                let vc = ATCGenericCollectionViewController(configuration: config)
                vc.genericDataSource = dataSource
                vc.use(adapter: ShoppingCartItemRowAdapter(uiConfig: uiConfig,
                                                           hostViewController: vc),
                           for: "ATCShoppingCartItem")
                VCs[order.id] = vc
            }
            let vc = VCs[order.id]!
            vc.view.frame = containerView.bounds
            containerView.addSubview(vc.view)
            cell.setNeedsLayout()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCAdminOrderCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        var h: CGFloat = 100 + 40 + 80 + 20

        if let order = object as? ATCOrder {
            h += CGFloat(order.totalItems()) * 35
        }
        return CGSize(width: containerBounds.width,
                      height: h)
    }
}

extension ATCAdminOrderRowAdapter: ATCAdminOrderCollectionViewCellDelegate {
    func cell(_ cell: ATCAdminOrderCollectionViewCell, didTapChangeStatusOrder order: ATCOrder) {
        selectedCell = cell
        bottomSelectVC = parentVC?.showBottomSelectControl(options: order.orderOptions(),
                                                           uiConfig: uiConfig,
                                                           delegate: self)
    }
}

extension ATCAdminOrderRowAdapter: CPKSelectBottomControlDelegate {
    func didPickOption(_ option: CPKSelectOptionModel) {
        selectedCell?.statusButton.setTitle(option.title, for: .normal)
        if let order = selectedCell?.viewModel {
            dsProvider.placeOrderManager?.updateOrder(order: order,
                                                      newStatus: option.title,
                                                      completion: {[weak self] (success) in
                                                        guard let `self` = self else { return }
                                                        if (success) {
                                                            self.parentVC?.genericDataSource?.loadFirst()
                                                        } else {
                                                            self.selectedCell?.statusButton.setTitle(order.status.uppercased(),
                                                                                                     for: .normal)
                                                        }
            })
        }
        selectedCell = nil
        bottomSelectVC?.view.removeFromSuperview()
        bottomSelectVC?.removeFromParent()
        bottomSelectVC = nil
    }

    func didDismiss() {
        selectedCell = nil
        bottomSelectVC?.view.removeFromSuperview()
        bottomSelectVC?.removeFromParent()
        bottomSelectVC = nil
    }
}
