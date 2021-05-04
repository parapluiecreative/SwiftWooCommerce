//
//  UIConfiguration.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 8/29/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

class UIConfiguration: ATCUIConfigurationProtocol, ATCUIGenericConfigurationProtocol {
    
    let colorGray0: UIColor = UIColor.darkModeColor(hexString: "#000000")
    let colorGray3: UIColor = UIColor.darkModeColor(hexString: "#333333")
    let colorGray9: UIColor = UIColor.darkModeColor(hexString: "#f4f4f4")

    var italicMediumFont: UIFont = UIFont(name: "FallingSkyCond", size: 14)!

    let mainThemeBackgroundColor: UIColor = UIColor.modedColor(light: "#ffffff", dark: "#121212")

    let mainThemeForegroundColor: UIColor = UIColor(hexString: "#5ea23a")

    let mainTextColor: UIColor = UIColor.darkModeColor(hexString: "#555555")

    let mainSubtextColor: UIColor = UIColor.darkModeColor(hexString: "#999999")

    let hairlineColor: UIColor = UIColor.darkModeColor(hexString: "#5ea23a")

    let regularSmallFont: UIFont = UIFont(name: "FallingSkyCond", size: 14)!

    let regularMediumFont: UIFont = UIFont(name: "FallingSky", size: 16)!

    let regularLargeFont: UIFont = UIFont(name: "FallingSky", size: 18)!

    let mediumBoldFont: UIFont = UIFont(name: "FallingSkyBd", size: 20)!

    let boldSmallFont: UIFont = UIFont(name: "FallingSkyBd", size: 20)!

    let boldLargeFont: UIFont = UIFont(name: "FallingSkyBd", size: 20)!

    let boldSuperLargeFont: UIFont = UIFont(name: "FallingSkyBd", size: 20)!

    func regularFont(size: CGFloat) -> UIFont {
        return UIFont(name: "FallingSky", size: size)!
    }
    func boldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "FallingSkyBd", size: size)!
    }
    
    func lightFont(size: CGFloat) -> UIFont {
        return UIFont(name: "FallingSkyCond", size: size)!
    }

    // General
    let mainThemeColor = UIColor.modedColor(light: "#ffffff", dark: "#121212")
    let regularSmallSizeFont: UIFont = UIFont(name: "FallingSky", size: 12)!
    let regularMediumSizeFont: UIFont = UIFont(name: "FallingSky", size: 16)!
    let regularLargeSizeFont: UIFont = UIFont(name: "FallingSky", size: 20)!
    let mainButtonBackgroundColor: UIColor = UIColor(hexString: "#5ea23a")
    let subtitleLabelColor = UIColor(hexString: "#999999")

    // Menu
    let menuItemFont = UIFont(name: "FallingSkyCond", size: 16)!
    let menuTintColor = UIColor(hexString: "#555555").darkModed
    let menuHomeImage = UIImage.localImage("home-shop-icon", template: true)
    let menuOrdersImage = UIImage.localImage("delivery-icon", template: true)
    let menuRestaurantMenuImage = UIImage.localImage("restaurant-menu", template: true)
    let menuSearchImage = UIImage.localImage("search-icon", template: true)
    let menuReservationMenuImage = UIImage.localImage("reservation-icon", template: true)

    let menuItemHeight: CGFloat = 45

    // Navigation
    let navigationMenuImage = UIImage.localImage("menu-icon", template: true)
    let navigationBarTitleColor = UIColor(hexString: "#555555")
    let navigationShoppingCartImage = UIImage.localImage("cart-icon", template: true)
    let navigationShoppingCartBadgedCountBackgroundColor = UIColor.red
    let navigationShoppingCartBadgedCountTextColor = UIColor.white

    // Status bar
    let statusBarStyle: UIStatusBarStyle = .default

    // Home screen
    let homeScreenTitle = "Home".localizedCore
    let categoriesTitle = "Menu".localizedEcommerce
    let homeScreenStoriesFont = UIFont(name: "FallingSkyCond", size: 14)!

    // Tab bar
    let tabBarBarTintColor = UIColor.white
    let homeTabBarItemTitle = "Home".localizedCore
    let categoriesTabBarItemTitle = "Shop".localizedEcommerce
    let cartTabBarItemTitle = "Cart".localizedEcommerce

    // Category screen
    let categoryScreenColorAlpha: CGFloat = 0.5
    let categoryScreenTitleLabelColor: UIColor = UIColor.white
    let categoryScreenTitleLabelAlpha: CGFloat = 1.0
    let categoryScreenCellHeight: CGFloat = 130
    let categoryScreenBackgroundColor = UIColor(displayP3Red: 246/255, green: 244/255, blue: 249/255, alpha: 1).darkModed
    let categoryScreenCellPadding: CGFloat = 7
    let categoryScreenTitleFont = UIFont(name: "FallingSkyCond", size: 18)!

    // Product list screen
    let productScreenCellHeight: CGFloat = 125
    let productScreenCellWidth: CGFloat = 150
    let productScreenBackgroundColor = UIColor(displayP3Red: 246/255, green: 244/255, blue: 249/255, alpha: 1).darkModed
    let productScreenTitleFont = UIFont(name: "FallingSkyCond", size: 18)!
    let productScreenPriceFont = UIFont(name: "FallingSkyCond", size: 16)!
    let productScreenDescriptionFont = UIFont(name: "FallingSkyCond", size: 14)!
    let productScreenDescriptionColor = UIColor(hexString: "#767475").darkModed
    let productScreenTextColor = UIColor(hexString: "#595959").darkModed
    let productScreenImageViewBorderColor = UIColor(displayP3Red: 169/255, green: 171/255, blue: 173/255, alpha: 1)

    // Product Details screen
    let productDetailsScreenImageBackground: UIColor = UIColor(hexString: "#F6F4F9", alpha: 0.6).darkModed
    let productDetailsCollectionViewCellSize: CGSize = CGSize(width: 80, height: 80)
    let productDetailsTitleFont: UIFont = UIFont(name: "FallingSkyCond", size: 20)!
    let productDetailsPriceBorderColor = UIColor(hexString: "#cccccc").darkModed
    let productDetailsTextColor = UIColor(hexString: "#56526D").darkModed
    let productDetailsPriceFont: UIFont = UIFont.boldSystemFont(ofSize: 20)
    let productDetailsAddToCartButtonFont: UIFont = UIFont.boldSystemFont(ofSize: 16)
    let productDetailsAddToCartButtonBgColor: UIColor = UIColor(hexString: "#5ea23a")
    let productDetailsDescriptionFont: UIFont = UIFont(name: "FallingSky", size: 16)!
    let productDetailsStepperierFont: UIFont = UIFont(name: "FallingSkyBd", size: 16)!

    // Cart Screen
    let cartScreenCellHeight: CGFloat = 63.0
    let cartScreenFooterCellHeight: CGFloat = 63.0
    let cartScreenBackgroundColor = UIColor.white
    let cartScreenTitle = "Your Cart".localizedEcommerce
    let cartScreenLabelColor = UIColor(hexString: "#3a3845")
    let cartScreenCountLabelColor = UIColor(hexString: "#5ea23a")
    let cartScreenCountBorderColor = UIColor(hexString: "#c0c0c2")
    let cartScreenTitleFont: UIFont = UIFont(name: "FallingSky", size: 16)!
    let cartScreenPriceFont: UIFont = UIFont(name: "FallingSky", size: 16)!
    let cartScreenCountFont: UIFont = UIFont(name: "FallingSkyBd", size: 16)!
    let cartScreenFooterPriceFont: UIFont = UIFont(name: "FallingSkyBd", size: 16)!
    let cartScreenFooterTotalPriceTextFont: UIFont = UIFont(name: "FallingSkyBd", size: 16)!
    let cartScreenFooterPriceColor = UIColor(hexString: "#56526D")
    let cartScreenFooterTotalPriceTextColor = UIColor(hexString: "#666666")
    let cartScreenCheckoutButtonFont: UIFont = UIFont(name: "FallingSky", size: 16)!
    let cartScreenCheckoutButtonHeight: CGFloat = 60.0
    let cartScreenCheckoutButtonTitle: String = "PLACE ORDER".localizedEcommerce
    let cartScreenCheckoutButtonBackgroundColor = UIColor(hexString: "#5ea23a")
    let cartScreenCheckoutButtonTextColor = UIColor.white

    // Orders Screen
    let ordersScreenCartItemCellHeight: CGFloat = 30.0
    let ordersScreenButtonFont: UIFont = UIFont(name: "FallingSky", size: 12)!
    let ordersScreenButtonHeight: CGFloat = 35.0
    let ordersScreenFooterPriceFont: UIFont = UIFont(name: "FallingSky", size: 16)!

    func configureUI() {
        UINavigationBar.appearance().barTintColor = mainThemeColor
        UINavigationBar.appearance().tintColor = navigationBarTitleColor

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: navigationBarTitleColor]
        UINavigationBar.appearance().isTranslucent = false

        UITabBar.appearance().tintColor = mainThemeColor
        UITabBar.appearance().barTintColor = tabBarBarTintColor
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = mainThemeColor
        }
    }
}
