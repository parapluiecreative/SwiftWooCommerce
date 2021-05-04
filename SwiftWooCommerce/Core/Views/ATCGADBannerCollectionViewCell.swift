//
//  ATCGADBannerCollectionViewCell.swift
//  WordpressApp
//
//  Created by Florian Marcu on 5/9/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ATCGADBannerCollectionViewCell: UICollectionViewCell {
    @IBOutlet var bannerView: GADBannerView!

    func configure(googleAd: ATCGoogleAd, adUnitID: String, viewController: UIViewController) {
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        bannerView.load(GADRequest())
    }
}
