//
//  ATCAddAuthoredProductManagerProtocol.swift
//  Shopertino
//
//  Created by Duy Bui on 1/29/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Foundation

protocol ATCAddAuthoredProductManagerProtocol {
    func addAuthoredProductManagerProtocol(userId: String?,
                                           product: Product?,
                                           completion: @escaping (_ success: Bool) -> Void)
}
