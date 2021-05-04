//
//  ATCPlaceOrderManagerProtocol.swift
//  Shopertino
//
//  Created by Florian Marcu on 5/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCPlaceOrderManagerProtocol: class {
    func placeOrder(user: ATCUser?,
                    address: ATCAddress?,
                    cart: ATCShoppingCart,
                    completion: @escaping (_ success: Bool) -> Void)
    func updateOrder(order: ATCOrder,
                     newStatus: String,
                     completion: ((_ success: Bool) -> Void)?)
}
