//
//  ATCSocialMediaSharingManager.swift
//  AppTemplatesFoundation
//
//  Created by Florian Marcu on 4/1/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import Social
import UIKit

public protocol ATCSocialMediaSharable {
    func image() -> UIImage?
    func url() -> URL?
    func text() -> String?
}

public class ATCSocialMediaSharingManager {
    public static func shareOnFacebook(object: ATCSocialMediaSharable, from presentingVC: UIViewController) {
        share(object: object, for: SLServiceTypeFacebook, from: presentingVC)
    }

    public static func shareOnTwitter(object: ATCSocialMediaSharable, from presentingVC: UIViewController) {
        share(object: object, for: SLServiceTypeTwitter, from: presentingVC)
    }

    private static func share(object: ATCSocialMediaSharable, for serviceType: String, from presentingVC: UIViewController) {
        if let composeVC = SLComposeViewController(forServiceType:serviceType) {
            composeVC.add(object.image())
            composeVC.add(object.url())
            composeVC.setInitialText(object.text())
            presentingVC.present(composeVC, animated: true, completion: nil)
        }
    }
}
