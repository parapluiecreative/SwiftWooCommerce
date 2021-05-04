//
//  ATCAddressesDataSourceProtocol.swift
//  Shopertino
//
//  Created by Mayil Kannan on 18/09/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

protocol ATCAddressesDataSourceProtocol: class {
    func addressDataSource(for user: ATCUser?) -> ATCGenericCollectionViewControllerDataSource?
}

