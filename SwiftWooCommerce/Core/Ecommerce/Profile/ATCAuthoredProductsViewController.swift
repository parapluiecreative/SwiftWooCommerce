//
//  ATCAuthoredProductsViewController.swift
//  Shopertino
//
//  Created by Duy Bui on 1/29/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Foundation
import UIKit

protocol ATCShopertinoDataSourceProvider {}

class ATCAuthoredProductsViewController: ATCGenericCollectionViewController {
    
    var user: ATCUser? {
        didSet {
            if let user = user {
                self.genericDataSource = dsProvider.authoredProducts(for: user.uid)
            }
        }
    }

    let dsProvider: ATCEcommerceDataSourceProvider
    let uiConfig: ATCUIGenericConfigurationProtocol
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         dsProvider: ATCEcommerceDataSourceProvider) {
        self.dsProvider = dsProvider
        self.uiConfig = uiConfig
        let layout = ATCLiquidCollectionViewLayout()
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Products".localizedInApp,
                                               description: "No products were added to the list.".localizedInApp,
                                               callToAction: "Add Product".localizedListing)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: .gray,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: emptyViewModel)
        super.init(configuration: configuration)
        self.use(adapter: ATCProductRowAdapter(uiConfig: uiConfig), for: "Product")
        self.title = "My Products".localizedInApp
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateProductsCollection), name: kShopertinoCollectionDidUpdateNotificationName, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.genericDataSource?.loadFirst()
    }
    
    override func handleEmptyViewCallToAction() {
        navigateToAddAuthoredProducts()
    }
    
    @objc fileprivate func didUpdateProductsCollection() {
        self.genericDataSource?.loadFirst()
    }
    
    private func updateNavigationButton() {
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.addProductButton())]
    }
    
    fileprivate func addProductButton() -> UIButton {
        let addProductButton = UIButton()
        addProductButton.configure(icon: UIImage.localImage("add-photo-icon", template: true), color: uiConfig.mainThemeForegroundColor)
        addProductButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(25)
            maker.height.equalTo(25)
        })
        addProductButton.addTarget(self, action: #selector(didTapAddProductButton), for: .touchUpInside)
        return addProductButton
    }
    
    @objc private func didTapAddProductButton() {
        navigateToAddAuthoredProducts()
    }
    
    private func navigateToAddAuthoredProducts() {
        let composerVC = ATCProductComposerViewController(uiConfig: uiConfig, user: user, dsProvider: dsProvider)
        self.navigationController?.present(composerVC, animated: true, completion: nil)
    }
}
