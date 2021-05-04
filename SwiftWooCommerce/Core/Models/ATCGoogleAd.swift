//
//  ATCGoogleAd.swift
//  WordpressApp
//
//  Created by Florian Marcu on 5/9/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import GoogleMobileAds
import UIKit

class ATCGoogleAd: ATCGenericBaseModel {
    var description: String {
        return ""
    }

    let googleAdRequest = GADRequest()

    init() {}
    required init(jsonDict: [String: Any]) {}
}
