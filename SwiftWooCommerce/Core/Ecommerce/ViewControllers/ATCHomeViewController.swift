//
//  HomeViewController.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 8/29/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class ATCHomeViewController: UIViewController {

    private var segmentedViewController: SJSegmentedViewController!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let newProductsVC = ATCProductCollectionViewControllerFactory.vc(title: "New", firebasePath: "products")
        let popularProductsVC = ATCProductCollectionViewControllerFactory.vc(title: "Popular", firebasePath: "products")
        let saleProductsVC = ATCProductCollectionViewControllerFactory.vc(title: "Sale", firebasePath: "products")

        let vcs = [newProductsVC, popularProductsVC, saleProductsVC]
        segmentedViewController = SJSegmentedViewController(headerViewController: nil, segmentControllers: vcs)
        segmentedViewController.segmentBackgroundColor = .white
        segmentedViewController.segmentTitleColor = ATCUIConfiguration.mainThemeColor
        segmentedViewController.selectedSegmentViewColor = ATCUIConfiguration.mainThemeColor
        addChildViewController(segmentedViewController)
        self.view.addSubview(segmentedViewController.view)

        segmentedViewController.view.snp.makeConstraints { (maker) -> Void in
            maker.top.equalTo(self.topLayoutGuide.snp.bottom)
            maker.left.right.equalTo(view)
            maker.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        segmentedViewController.didMove(toParentViewController: self)
    }

    private func commonInit() {
        title = ATCUIConfiguration.homeScreenTitle
        tabBarItem = UITabBarItem(title: ATCUIConfiguration.homeTabBarItemTitle, image: ATCUIConfiguration.homeTabBarItemImage, selectedImage: ATCUIConfiguration.homeTabBarItemSelectedImage).tabBarWithNoTitle()
    }
}
