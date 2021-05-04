//
//  UIViewController.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/27/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//

import SwiftUI
import UIKit

extension UIViewController {
    func showBottomSelectControl(options: [CPKSelectOptionModel],
                                 uiConfig: ATCUIGenericConfigurationProtocol,
                                 delegate: CPKSelectBottomControlDelegate?) -> UIViewController {
        var selectControl = CPKSelectBottomControl(options: options,
                                                   tintColor: uiConfig.mainThemeForegroundColor,
                                                   isOpen: true)
        selectControl.delegate = delegate
        let viewController = UIHostingController(rootView: selectControl)
        self.addChildViewControllerWithView(viewController)
        viewController.view.frame = self.view.bounds
        viewController.view.backgroundColor = .clear
        return viewController
    }
}
