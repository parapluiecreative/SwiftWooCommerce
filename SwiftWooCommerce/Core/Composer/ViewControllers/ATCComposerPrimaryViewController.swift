//
//  ATCComposerPrimaryViewController.swift
//  ListingApp
//
//  Created by Florian Marcu on 10/6/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import CoreLocation
import UIKit

class ATCComposerPrimaryViewController: ATCGenericCollectionViewController {
    let dataSource: ATCGenericCollectionViewControllerDataSource
    var composerState: ATCComposerState
    let uiConfig: ATCUIGenericConfigurationProtocol
    let dsProvider: ATCListingDataSourcesProvider
    let imageComposerVC: ATCComposerPhotoGalleryViewController
    let firebaseWriter: ATCComposerFirebaseListingWriter

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         composerState: ATCComposerState,
         dsProvider: ATCListingDataSourcesProvider) {
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

        self.firebaseWriter = dsProvider.listingWriter
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
            ATCText(text: "Filters".localizedCore, accessoryText: "Select...".localizedCore),
            ATCText(text: "Location".localizedCore, accessoryText: "Select...".localizedCore),
            imageComposerCarouselModel
            ])

        self.composerState = composerState
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
                        guard let strongSelf = self else { return }
                        guard let price = alert.textFields?.first?.text else {
                            return
                        }
                        if let obj = strongSelf.dataSource.object(at: 5) as? ATCText {
                            obj.accessoryText = price
                            strongSelf.collectionView?.reloadData()
                        }
                        strongSelf.composerState.price = price
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                } else if (textModel.text == "Category".localizedComposer) {
                    self.didTapCategoryItem()
                } else if (textModel.text == "Filters".localizedCore) {
                    guard let category = self.composerState.category else {
                        self.showErrorMessage("Please select a category first.".localizedComposer)
                        return
                    }
                    let vc = ATCFiltersViewController(uiConfig: self.uiConfig,
                                                      dataSource: self.dsProvider.filtersDataSource(for: category.id),
                                                      categoryID: category.id,
                                                      localFiltersStore: nil)
                    vc.title = "Filters".localizedCore
                    vc.delegate = self
                    let navVC = UINavigationController(rootViewController: vc)
                    self.present(navVC, animated: true, completion: nil)
                } else if (textModel.text == "Location".localizedCore) {
                    let vc = LocationPicker()
                    vc.addBarButtons()
                    vc.pickCompletion = {[weak self] (pickedLocationItem) in
                        guard let `self` = self else { return }
                        self.composerState.latitude = pickedLocationItem.coordinate?.latitude
                        self.composerState.longitude = pickedLocationItem.coordinate?.longitude
                        self.composerState.location = pickedLocationItem.name

                        if let obj = self.dataSource.object(at: 8) as? ATCText {
                            obj.accessoryText = pickedLocationItem.name
                            self.collectionView?.reloadData()
                        }
                    }
                    self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
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
        nextButton.setTitle("Add New Place".localizedComposer, for: .normal)
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

        // Show the screen, despite user being incomplete.
        sanityCheck()
    }

    private func setupDataSource() {
        genericDataSource = dataSource
        collectionView?.reloadData()
    }

    @objc private func didTapCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc private func didTapNext() {
        if !sanityCheck() {
            return
        }
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: 2, section: 0)) as? ATCFormTextFieldCollectionViewCell {
            self.composerState.title = cell.textView.text
            if ((self.composerState.title?.count ?? 0) == 0) {
                showErrorMessage("Please enter a title.".localizedComposer)
                return
            }
        }
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: 4, section: 0)) as? ATCFormTextFieldCollectionViewCell {
            self.composerState.description = cell.textView.text
            if ((self.composerState.description?.count ?? 0) == 0) {
                showErrorMessage("Please enter a description.".localizedComposer)
                return
            }
        }
        if (self.composerState.price ?? "").count == 0 {
            showErrorMessage("Please enter a price.".localizedComposer)
            return
        }

        if self.composerState.category == nil {
            showErrorMessage("You must choose a category.".localizedComposer)
            return
        }

        if self.composerState.filters == nil {
            showErrorMessage("You must configure all the filters.".localizedComposer)
            return
        }

        if let dataSource = imageComposerVC.genericDataSource as? ATCGenericLocalDataSource<ATCFormImageViewModel> {
            let items = dataSource.items
            if items.count == 1 {
                showErrorMessage("You must upload at least one photo.".localizedComposer)
                return
            }
            self.composerState.images = items.compactMap({ $0.image })
        }

        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
        hud.show(in: self.view)
        firebaseWriter.save(state: composerState, user: ATCListingHostViewController.loggedInUser) {[weak self] in
            guard let `self` = self else { return }
            hud.dismiss()
            self.showErrorMessage("The listing was successfully posted.".localizedComposer, completion: {[weak self] in
                guard let `self` = self else { return }
                self.navigationController?.dismiss(animated: true, completion: nil)
            })
        }
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
        vc.genericDataSource = self.dsProvider.categoriesDataSource
        vc.use(adapter: ATCTextRowAdapter(font: uiConfig.boldFont(size: 16),
                                          textColor: uiConfig.mainTextColor,
                                          staticHeight: 60,
                                          bgColor: uiConfig.mainThemeBackgroundColor),
               for: "ATCListingCategory")

        let nav = UINavigationController(rootViewController: vc)
        vc.selectionBlock = {[weak self] (navigationController, object, indexPath) in
            guard let `self` = self else { return }
            if let selectedCategory = object as? ATCListingCategory {
                // If category changed, we need to reset the filters
                if (self.composerState.category != selectedCategory) {
                    self.composerState.filters = nil
                    if let obj = self.dataSource.object(at: 7) as? ATCText {
                        obj.accessoryText = "Select...".localizedCore
                    }
                }
                self.composerState.category = selectedCategory

                if let obj = self.dataSource.object(at: 6) as? ATCText {
                    obj.accessoryText = selectedCategory.title
                    self.collectionView?.reloadData()
                }
                navigationController?.dismiss(animated: true, completion: nil)
            }
        }

        self.present(nav, animated: true, completion: nil)
    }

    private func showErrorMessage(_ string: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: string, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .cancel, handler: { (action) in
            if let completion = completion {
                completion()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func sanityCheck() -> Bool {
        guard let user = ATCListingHostViewController.loggedInUser else {
            showErrorMessage("You need to log in, in order to post a listing.".localizedComposer)
            return false
        }
        if (user.uid?.count ?? 0) <= 0
            || (user.profilePictureURL?.count ?? 0) <= 0
            || user.hasDefaultAvatar
            || user.fullName().count <= 0 {
            showErrorMessage("You can't submit a listing, unless you have a complete profile. Please make sure you uploaded a profile picture, and you specified your full name.".localizedComposer)
            return false
        }
        return true
    }
}

extension ATCComposerPrimaryViewController: ATCFiltersViewControllerDelegate {
    func filtersViewController(_ vc: ATCFiltersViewController, didUpdateTo filters: [ATCSelectFilter]) {
        self.composerState.filters = filters
        if let obj = self.dataSource.object(at: 7) as? ATCText {
            obj.accessoryText = ""
            self.collectionView?.reloadData()
        }
    }
}
