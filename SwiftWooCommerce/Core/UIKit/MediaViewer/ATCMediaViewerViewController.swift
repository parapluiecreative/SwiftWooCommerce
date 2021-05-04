//
//  ATCSocialNetworkImageViewer.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 16/07/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCMediaViewerViewController : ATCGenericCollectionViewController {
    let uiConfig : ATCUIGenericConfigurationProtocol
    var datasource: [ATCImage] = [] {
        didSet {
            setupDataSource()
        }
    }
    let cellId = "ATCImage"
    var firstTime: Bool = false
    var selectedIndexPath = IndexPath()

    var dismissButton : ATCDismissButton = {
        let button = ATCDismissButton()
        button.translatesAutoresizingMaskIntoConstraints = true
        button.addTarget(self, action: #selector(handleDismissButton), for: .touchUpInside)
        return button
    }()

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig

        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: .white,
                                                                            collectionViewBackgroundColor: .black,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: true,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        super.init(configuration: configuration)
        configureDismissButton()
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (!firstTime) {
            collectionView.scrollToItem(at: selectedIndexPath, at: .left, animated: false)
            firstTime.toggle()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK - Handlers
    @objc func handleDismissButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupDataSource() {
        let ds = ATCGenericLocalHeteroDataSource(items: datasource)
        let adapter =  ATCMediaViewerImageCellAdapter(uiConfig: uiConfig)
        adapter.delegate = self
        self.use(adapter: adapter, for: "ATCImage")
        self.genericDataSource = ds
        self.genericDataSource?.loadFirst()
    }
    
    override func registerReuseIdentifiers() {
        collectionView.register(ATCMediaViewerImageCell.self, forCellWithReuseIdentifier: cellId)
    }
    func configureDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ATCMediaViewerViewController : ATCMediaViewerImageCellAdapterDelegate {
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
