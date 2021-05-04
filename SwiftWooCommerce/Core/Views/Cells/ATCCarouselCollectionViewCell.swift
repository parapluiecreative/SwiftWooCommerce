//
//  ATCCarouselCollectionViewCell.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 4/25/18.
//  Copyright © 2018 iOS App Templates. All rights reserved.
//

import UIKit

class ATCGridViewModel: ATCCarouselViewModel {
    let callToAction: String?
    let callToActionBlock: (() -> Void)?

    init(title: String?,
         viewController: ATCGenericCollectionViewController,
         cellHeight: CGFloat,
         pageControlEnabled: Bool = false,
         callToAction: String? = nil,
         callToActionBlock: (() -> Void)? = nil) {
        self.callToAction = callToAction
        self.callToActionBlock = callToActionBlock
        super.init(title: title, viewController: viewController, cellHeight: cellHeight)
    }

    required init(jsonDict: [String : Any]) {
        fatalError("init(jsonDict:) has not been implemented")
    }
}

struct ATCCarouselViewModelConfiguration {
    var titleAlignment: NSTextAlignment?
}

class ATCCarouselViewModel: ATCGenericBaseModel {
    var description: String = "Carousel".localizedCore

    let cellHeight: CGFloat
    let title: String?
    let pageControlEnabled: Bool
    var viewController: ATCGenericCollectionViewController
    let config: ATCCarouselViewModelConfiguration?
    weak var parentViewController: UIViewController?

    init(title: String?,
         viewController: ATCGenericCollectionViewController,
         config: ATCCarouselViewModelConfiguration? = nil,
         cellHeight: CGFloat,
         pageControlEnabled: Bool = false) {
        self.title = title
        self.cellHeight = cellHeight
        self.config = config
        self.viewController = viewController
        self.pageControlEnabled = pageControlEnabled
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }
}

class ATCCarouselCollectionViewCell: UICollectionViewCell, ATCGenericCollectionViewScrollDelegate {
    @IBOutlet var carouselTitleLabel: UILabel!
    @IBOutlet var carouselContainerView: UIView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var containerView: UIView!

    var oldTitleConstraints: [NSLayoutConstraint]? = nil

    func configure(viewModel: ATCCarouselViewModel, uiConfig: ATCUIGenericConfigurationProtocol) {
        if (viewModel.title == nil) {
            oldTitleConstraints = []
            if let parentConstraints = carouselTitleLabel.superview?.constraints {
                for con in parentConstraints {
                    if let fItem = con.firstItem as? UIView, let sItem = con.secondItem as? UIView {
                        if fItem == carouselTitleLabel || sItem == carouselTitleLabel {
                            oldTitleConstraints?.append(con)
                        }
                    }
                }
            }
            carouselTitleLabel.removeFromSuperview()
        } else {
            if (nil == carouselTitleLabel.superview) {
                self.addSubview(carouselTitleLabel)
                if let oldTitleConstraints = oldTitleConstraints {
                    self.addConstraints(oldTitleConstraints)
                }
            }
        }
        carouselTitleLabel.text = viewModel.title
        carouselTitleLabel.font = uiConfig.boldLargeFont
        carouselTitleLabel.textColor = uiConfig.mainTextColor
        if let titleAlignment = viewModel.config?.titleAlignment {
            carouselTitleLabel.textAlignment = titleAlignment
        } else {
            carouselTitleLabel.textAlignment = ATCLocalizationHelper.isRTLLanguage ? .right: .left
        }

        carouselContainerView.setNeedsLayout()
        carouselContainerView.layoutIfNeeded()
        carouselContainerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        containerView.backgroundColor = uiConfig.mainThemeBackgroundColor

        let viewController = viewModel.viewController

        pageControl.isHidden = !viewModel.pageControlEnabled
        if let dS = viewController.genericDataSource {
            pageControl.numberOfPages = dS.numberOfObjects()
        }
        viewController.scrollDelegate = self

        viewController.view.frame = carouselContainerView.bounds
        carouselContainerView.addSubview(viewController.view)
        self.setNeedsLayout()
        viewModel.parentViewController?.addChild(viewModel.viewController)
        self.backgroundColor = .clear
    }

    func genericScrollView(_ scrollView: UIScrollView, didScrollToPage page: Int) {
        pageControl.currentPage = page
    }
    
    func genericScrollViewDidScroll(_ scrollView: UIScrollView) {}
}
