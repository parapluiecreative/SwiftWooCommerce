//
//  ATCGenericUIConfiguration.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/9/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCGenericUIConfiguration {
    static let shared: ATCUIGenericConfigurationProtocol = ATCDefaultUIConfiguration()
}

class ATCDefaultUIConfiguration: ATCUIGenericConfigurationProtocol {

    static let shared: ATCDefaultUIConfiguration = ATCDefaultUIConfiguration()

    let mainThemeBackgroundColor: UIColor = .white
    let mainThemeForegroundColor: UIColor = UIColor(hexString: "#ff5a66")
    let mainTextColor: UIColor = UIColor(hexString: "#464646")
    let mainSubtextColor: UIColor = UIColor(hexString: "#dddddd")
    let statusBarStyle: UIStatusBarStyle = .default
    let hairlineColor: UIColor = UIColor(hexString: "#d6d6d6")
    var colorGray0: UIColor = .black
    var colorGray3: UIColor = UIColor(hexString: "#333333")
    var colorGray9: UIColor = UIColor(hexString: "#f4f4f4")

    let regularSmallFont = UIFont.systemFont(ofSize: 12)
    let regularMediumFont = UIFont.systemFont(ofSize: 14)
    let regularLargeFont = UIFont.systemFont(ofSize: 18)
    let mediumBoldFont = UIFont.boldSystemFont(ofSize: 14)
    let boldLargeFont = UIFont.boldSystemFont(ofSize: 24)
    let boldSmallFont = UIFont.boldSystemFont(ofSize: 12)
    let boldSuperSmallFont = UIFont.boldSystemFont(ofSize: 10)
    let boldSuperLargeFont = UIFont.boldSystemFont(ofSize: 30)
    let italicMediumFont = UIFont(name: "TrebuchetMS-Italic", size: 14)!

    let homeImage = UIImage.localImage("home-icon", template: true)
    let categoriesImage = UIImage.localImage("categories-icon", template: true)
    let composeImage = UIImage.localImage("compose-icon", template: true)
    let savedImage = UIImage.localImage("heart-icon", template: true)
    let searchImage = UIImage.localImage("search-icon", template: true)

    func regularFont(size: CGFloat) -> UIFont {
       return UIFont.systemFont(ofSize: size)
    }
    func lightFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }
    func boldFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    func configureUI() {}
    func configureTabBarUI(tabBar: UITabBar) {}
}
