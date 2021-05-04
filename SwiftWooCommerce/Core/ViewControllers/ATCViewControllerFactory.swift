//
//  ATCViewControllerFactory.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 5/15/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ATCViewControllerFactory {

    static func storiesViewController(dataSource: ATCGenericCollectionViewControllerDataSource,
                                      uiConfig: ATCUIGenericConfigurationProtocol,
                                      minimumInteritemSpacing: CGFloat = 0,
                                      selectionBlock: ATCollectionViewSelectionBlock?) -> ATCGenericCollectionViewController {
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.minimumLineSpacing = minimumInteritemSpacing
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
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
        let vc = ATCGenericCollectionViewController(configuration: configuration, selectionBlock: selectionBlock)
        // vc.genericDataSource = ATCGenericLocalDataSource<ATCStoryViewModel>(items: stories)
        vc.genericDataSource = dataSource

        return vc
    }
}
