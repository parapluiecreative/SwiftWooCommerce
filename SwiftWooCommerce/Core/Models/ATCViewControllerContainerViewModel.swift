//
//  ATCViewControllerContainerModel.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/12/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCViewControllerContainerViewModel: ATCGenericBaseModel {

    var description: String = "Carousel".localizedCore

    let cellHeight: CGFloat?
    let subcellHeight: CGFloat?
    let minTotalHeight: CGFloat
    var viewController: UIViewController
    weak var parentViewController: UIViewController?

    init(viewController: UIViewController,
         cellHeight: CGFloat? = nil,
         subcellHeight: CGFloat? = nil,
         minTotalHeight: CGFloat = 0) {
        self.cellHeight = cellHeight
        self.subcellHeight = subcellHeight
        self.viewController = viewController
        self.minTotalHeight = minTotalHeight

        if let _ = cellHeight, let _ = subcellHeight {
            fatalError("Choose either static or dynamic size. You can't have both.")
        }
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }
}
