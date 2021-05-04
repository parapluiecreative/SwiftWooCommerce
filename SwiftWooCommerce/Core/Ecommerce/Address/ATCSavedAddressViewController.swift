//
//  ATCSavedAddressViewController.swift
//  Shopertino
//
//  Created by Mayil Kannan on 15/09/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

protocol ATCSavedAddressViewControllerDelegate: class {
    func didSelectAddress(address: ATCAddress)
}

class ATCSavedAddressViewController: ATCGenericCollectionViewController {
    var viewer: ATCUser?
    var isCheckoutHappening: Bool = false
    var delegate: ATCSavedAddressViewControllerDelegate?
    let dsProvider: ATCEcommerceDataSourceProvider?
    
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider?,
         viewer: ATCUser?) {
        self.viewer = viewer
        self.dsProvider = dsProvider
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Address".localizedEcommerce,
                                               description: "No customer saved any address yet. All shipping addresses will be displayed here.".localizedEcommerce,
                                               callToAction: nil)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: true,
                                                                            pullToRefreshTintColor: .white,
                                                                            collectionViewBackgroundColor: UIColor.darkModeColor(hexString: "#f4f6f9"),
                                                                            collectionViewLayout: ATCLiquidCollectionViewLayout(cellPadding: 5),
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: emptyViewModel)
        super.init(configuration: configuration)
        if let dsProvider = dsProvider as? ATCAddressesDataSourceProtocol {
            self.genericDataSource = dsProvider.addressDataSource(for: viewer)
        }
        self.use(adapter: ATCAddressRowAdapter(parentVC: self,
                                            uiConfig: uiConfig,
                                            viewer: viewer,
                                            dsProvider: dsProvider),
                 for: "ATCAddress")
        self.selectionBlock = {[weak self] (navigationController, object, indexPath) in
            guard let self = self else { return }
            if self.isCheckoutHappening, let address = object as? ATCAddress {
                self.delegate?.didSelectAddress(address: address)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Shipping Addresses".localizedEcommerce
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd() {
        if let viewer = viewer {
            let createAddressVC = ATCCreateAddressViewController(user: viewer,
                                                                 dsProvider: dsProvider)
            createAddressVC.delegate = self
            let navController = UINavigationController(rootViewController: createAddressVC)
            self.present(navController, animated: true, completion: nil)
        }
    }
}

extension ATCSavedAddressViewController: ATCCreateAddressViewControllerDelegate {
    func createAddressVCDidUpdateAddress() {
        self.genericDataSource?.loadFirst()
    }
}
