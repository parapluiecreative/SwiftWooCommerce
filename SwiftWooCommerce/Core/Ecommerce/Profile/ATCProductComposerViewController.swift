//
//  ATCProductComposerViewController.swift
//  Shopertino
//
//  Created by Duy Bui on 1/29/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Foundation
import UIKit

class ATCProductComposerViewController: ATCGenericCollectionViewController {
    
    let dataSource: ATCGenericCollectionViewControllerDataSource
    let uiConfig: ATCUIGenericConfigurationProtocol
    let dsProvider: ATCEcommerceDataSourceProvider
    let imageComposerVC: ATCComposerPhotoGalleryViewController
    let user: ATCUser?
    private var composerState = Product()
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         user: ATCUser?,
         dsProvider: ATCEcommerceDataSourceProvider) {
        self.user = user
        let layout = ATCLiquidCollectionViewLayout(cellPadding: 0)
        let vcConfig = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                       pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                       collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                       collectionViewLayout: layout,
                                                                       collectionPagingEnabled: false,
                                                                       hideScrollIndicators: true,
                                                                       hidesNavigationBar: false,
                                                                       headerNibName: nil,
                                                                       scrollEnabled: true,
                                                                       uiConfig: uiConfig,
                                                                       emptyViewModel: nil)

        self.imageComposerVC = ATCComposerPhotoGalleryViewController(uiConfig: uiConfig)
        let imageComposerCarouselModel = ATCCarouselViewModel(title: "Add Photos".localizedComposer,
                                                              viewController: imageComposerVC,
                                                              cellHeight: 150)
        self.dataSource = ATCGenericLocalHeteroDataSource(items: [
            ATCDivider(),
            ATCText(text: "Title".localizedComposer),
            ATCFormTextFieldViewModel(title: "Title".localizedComposer, identifier: "title"),
            ATCText(text: "Description".localizedComposer),
            ATCFormTextFieldViewModel(title: "Description".localizedComposer, identifier: "description"),
            ATCText(text: "Price".localizedComposer, accessoryText: "Select...".localizedCore),
            ATCText(text: "Category".localizedComposer, accessoryText: "Select...".localizedCore),
            imageComposerCarouselModel
            ])
        self.uiConfig = uiConfig
        self.dsProvider = dsProvider

        super.init(configuration: vcConfig)

        imageComposerCarouselModel.parentViewController = self
        use(adapter: ATCDividerRowAdapter(titleFont: uiConfig.boldSuperLargeFont, minHeight: 10, titleColor: uiConfig.mainTextColor), for: "ATCDivider")
        use(adapter: ATCFormTextViewAdapter(uiConfig: uiConfig, height: 80), for: "ATCFormTextFieldViewModel")
        use(adapter: ATCTextRowAdapter(font: uiConfig.boldFont(size: 18),
                                       textColor: uiConfig.mainTextColor,
                                       staticHeight: 50,
                                       bgColor: uiConfig.mainThemeBackgroundColor),
            for: "ATCText")
        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectionBlock = {[weak self] (navigationController, object, indexPath) in
            guard let `self` = self else { return }
            
            if let textModel = object as? ATCText {
                if textModel.text == "Price".localizedComposer {
                    let alert = UIAlertController(title: "Enter Price (e.g. $150)".localizedComposer, message: "", preferredStyle: UIAlertController.Style.alert)
                    alert.addTextField(configurationHandler: { (textField) in
                        textField.placeholder = "Enter price...".localizedComposer
                    })
                    alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: {[weak self] (action) in
                        guard let self = self else { return }
                        guard let price = alert.textFields?.first?.text else {
                            return
                        }
                        if let obj = self.dataSource.object(at: 5) as? ATCText {
                            obj.accessoryText = price
                            self.collectionView?.reloadData()
                        }
                        self.composerState.price = price
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else if (textModel.text == "Category".localizedComposer) {
                    self.didTapCategoryItem()
                }
            }
        }

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        let nextButton = UIButton(type: .custom)
        nextButton.configure(color: .white,
                             font: uiConfig.mediumBoldFont,
                             cornerRadius: 5,
                             borderColor: nil,
                             backgroundColor: uiConfig.mainThemeForegroundColor,
                             borderWidth: nil)
        nextButton.setTitle("Add New Product".localizedComposer, for: .normal)
        view.addSubview(nextButton)

        nextButton.snp.makeConstraints { (maker) in
            maker.height.equalTo(50)
            maker.left.equalTo(view).offset(10)
            maker.right.equalTo(view).offset(-10)
            maker.bottom.equalTo(view.snp.bottom).offset(-40)
        }
        view.bringSubviewToFront(nextButton)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDataSource()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupDataSource() {
        genericDataSource = dataSource
        collectionView?.reloadData()
    }

    @objc private func didTapCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc private func didTapNext() {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: 2, section: 0)) as? ATCFormTextFieldCollectionViewCell {
            self.composerState.title = cell.textView.text
            if self.composerState.title.count == 0 {
                showMessage("Please enter a title.".localizedComposer)
                return
            }
        }
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: 4, section: 0)) as? ATCFormTextFieldCollectionViewCell {
            self.composerState.productDescription = cell.textView.text
            if self.composerState.productDescription.count == 0 {
                showMessage("Please enter a description.".localizedComposer)
                return
            }
        }
        if self.composerState.price.count == 0 {
            showMessage("Please enter a price.".localizedComposer)
            return
        }

        if self.composerState.categoryID == nil {
            showMessage("You must choose a category.".localizedComposer)
            return
        }

        if let dataSource = imageComposerVC.genericDataSource as? ATCGenericLocalDataSource<ATCFormImageViewModel> {
            let items = dataSource.items
            if items.count == 1 {
                showMessage("You must upload at least one photo.".localizedComposer)
                return
            }
            self.composerState.uploadImages = items.compactMap({ $0.image })
        }

        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
        hud.show(in: self.view)
        
        dsProvider.addAuthoredProduct?.addAuthoredProductManagerProtocol(userId: user?.uid, product: composerState, completion: { [weak self] (result) in
            hud.dismiss()
            guard let self = self else { return }
            if result {
                self.showMessage("Your product was successfully added.".localizedComposer, completion: {[weak self] in
                    self?.dismiss(animated: true, completion: nil)
                })
            } else {
                self.showMessage("Oops, something went wrong. Please try later".localizedComposer)
            }
        })
    }

    func didTapCategoryItem() {
        let layout = ATCLiquidCollectionViewLayout(cellPadding: 0)
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: .white,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        let vc = ATCGenericCollectionViewController(configuration: configuration)
        vc.title = "Choose Category".localizedComposer
        vc.genericDataSource = dsProvider.categoriesDataSource
        vc.use(adapter: ATCTextRowAdapter(font: uiConfig.boldFont(size: 16),
                                          textColor: uiConfig.mainTextColor,
                                          staticHeight: 60,
                                          bgColor: uiConfig.mainThemeBackgroundColor),
               for: "Category")

        let nav = UINavigationController(rootViewController: vc)
        vc.selectionBlock = {[weak self] (navigationController, object, indexPath) in
            guard let `self` = self else { return }
            if let selectedCategory = object as? Category {
                // If category changed, we need to reset the filters
                if (self.composerState.categoryID != selectedCategory.id) {
                    if let obj = self.dataSource.object(at: 7) as? ATCText {
                        obj.accessoryText = "Select...".localizedCore
                    }
                }
                self.composerState.categoryID = selectedCategory.id

                if let obj = self.dataSource.object(at: 6) as? ATCText {
                    obj.accessoryText = selectedCategory.title
                    self.collectionView?.reloadData()
                }
                navigationController?.dismiss(animated: true, completion: nil)
            }
        }

        self.present(nav, animated: true, completion: nil)
    }

    private func showMessage(_ string: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: string, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .cancel, handler: { (action) in
            if let completion = completion {
                completion()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
