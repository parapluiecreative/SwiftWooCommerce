//
//  ATCAdminSingleOrderViewControllerCollectionViewController.swift
//  RestaurantApp
//
//  Created by Florian Marcu on 11/26/19.
//  Copyright © 2019 iOS App Templates. All rights reserved.
//
import UIKit

class ATCAdminSingleOrderViewController: UIViewController {
    let order: ATCOrder

    init(order: ATCOrder) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
