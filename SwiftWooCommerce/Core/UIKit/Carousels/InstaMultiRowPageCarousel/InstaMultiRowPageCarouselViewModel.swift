//
//  InstaMultiRowPageCarouselViewModel.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/26/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class InstaMultiRowPageCarouselViewModel: ATCGenericBaseModel {
    var description: String = "InstaMultiRowPageCarouselViewModel"

    let cellHeight: CGFloat
    let title: String
    var viewController: ATCGenericCollectionViewController
    weak var parentViewController: UIViewController?

    init(title: String, viewController: ATCGenericCollectionViewController, cellHeight: CGFloat) {
        self.cellHeight = cellHeight
        self.title = title
        self.viewController = viewController
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }
}
