//
//  ProductImagesViewController.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/5/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ProductImageDelegate: class {
    func didLoad(_ image: UIImage)
}

class ProductImagesViewController: ATCGenericCollectionViewController {
    init(product: Product,
         uiConfig: ATCUIGenericConfigurationProtocol,
         imageDelegate: ProductImageDelegate?,
         cellHeight: CGFloat) {
        let layout = ATCCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: .white,
                                                                            collectionViewBackgroundColor: .white,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: false,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        super.init(configuration: configuration) { (nav, model, index) in
        }

        let imagesVC = ImagesViewController(product: product,
                                            imageDelegate: imageDelegate,
                                            uiConfig: uiConfig)
        let carouselConfig = ATCCarouselViewModelConfiguration(titleAlignment: nil)
        let carouselViewModel = ATCCarouselViewModel(title: nil,
                                                     viewController: imagesVC,
                                                     config: carouselConfig,
                                                     cellHeight: cellHeight,
                                                     pageControlEnabled: true)
        carouselViewModel.parentViewController = self
        self.genericDataSource = ATCGenericLocalDataSource(items: [carouselViewModel])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ImagesViewController: ATCGenericCollectionViewController {
    weak var imageDelegate: ProductImageDelegate?

    init(product: Product,
         imageDelegate: ProductImageDelegate?,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        self.imageDelegate = imageDelegate

        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: true,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        super.init(configuration: configuration) { (nav, model, index) in
        }
        self.genericDataSource = ATCGenericLocalDataSource(items: product.images.map({ATCImage($0)}))
        let adapter =  ATCImageRowAdapter(contentMode: .scaleAspectFill,
                                          cornerRadius: 0)
        adapter.delegate = self
        self.use(adapter: adapter,
                 for: "ATCImage")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImagesViewController: ATCImageRowAdapterDelegate {
    func imageRowAdapter(_ adapter: ATCImageRowAdapter, didLoad image: UIImage) {
        imageDelegate?.didLoad(image)
    }
}
