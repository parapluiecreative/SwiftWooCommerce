//
//  ATCSocialUserManagerProtocol.swift
//  CryptoApp
//
//  Created by Florian Marcu on 6/29/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

let kATCLoggedInUserDataDidChangeNotification = Notification.Name("kATCLoggedInUserDataDidChangeNotification")

protocol ATCSocialUserManagerProtocol: class {
    func fetchUser(userID: String, completion: @escaping (_ user: ATCUser?, _ error: Error?) -> Void)
}
