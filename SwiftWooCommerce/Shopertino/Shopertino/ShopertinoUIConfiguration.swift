//
//  ShopertinoUIConfiguration.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ShopertinoUIConfiguration: ATCUIGenericConfigurationProtocol {
    

    let colorGray0: UIColor = UIColor.darkModeColor(hexString: "#000000")
    let colorGray3: UIColor = UIColor.darkModeColor(hexString: "#333333")
    let colorGray9: UIColor = UIColor.darkModeColor(hexString: "#f4f4f4")



    
    
    let mainThemeBackgroundColor: UIColor = UIColor.modedColor(light: "#ffffff", dark: "#121212")

    let mainThemeForegroundColor: UIColor = UIColor(hexString: "#333333")// "#ac73ff")

    let mainTextColor: UIColor = UIColor.darkModeColor(hexString: "#555555")

    let mainSubtextColor: UIColor = UIColor.darkModeColor(hexString: "#999999")

    let hairlineColor: UIColor = UIColor.darkModeColor(hexString: "#cccccc")
    

    var italicMediumFont: UIFont = UIFont(name: "Oswald-Regular", size: 14)!

            
    let regularSmallFont: UIFont = UIFont(name: "Oswald-Regular", size: 14)!

    let regularMediumFont: UIFont = UIFont(name: "Oswald-Regular", size: 16)!

    let regularLargeFont: UIFont = UIFont(name: "Oswald-Regular", size: 18)!

    let mediumBoldFont: UIFont = UIFont(name: "Oswald-SemiBold", size: 20)!

    let boldSmallFont: UIFont = UIFont(name: "Oswald-SemiBold", size: 20)!

    let boldLargeFont: UIFont = UIFont(name: "Oswald-SemiBold", size: 26)!

    let boldSuperLargeFont: UIFont = UIFont(name: "Oswald-SemiBold", size: 20)!

    func regularFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Oswald-Regular", size: size)!
    }
    
    func boldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Oswald-Bold", size: size)!
    }
    
    func lightFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Oswald-SemiBold", size: size)!
    }

    // General
    let mainThemeColor = UIColor.modedColor(light: "#ffffff", dark: "#121212")
    let regularSmallSizeFont: UIFont = UIFont(name: "FallingSky", size: 12)!
    let regularMediumSizeFont: UIFont = UIFont(name: "FallingSky", size: 16)!
    let regularLargeSizeFont: UIFont = UIFont(name: "FallingSky", size: 20)!
    let mainButtonBackgroundColor: UIColor = UIColor.darkModeColor(hexString: "#5ea23a")
    let subtitleLabelColor = UIColor.darkModeColor(hexString: "#999999")

    // Menu
    let menuItemFont = UIFont(name: "FallingSkyCond", size: 16)!
    let menuTintColor = UIColor.darkModeColor(hexString: "#555555")
    let menuHomeImage = UIImage.localImage("home-shop-icon", template: true)
    let menuOrdersImage = UIImage.localImage("delivery-icon", template: true)
    let menuRestaurantMenuImage = UIImage.localImage("restaurant-menu", template: true)
    let menuSearchImage = UIImage.localImage("search-icon", template: true)
    let menuReservationMenuImage = UIImage.localImage("reservation-icon", template: true)

    // Navigation
    let navigationMenuImage = UIImage.localImage("menu-icon", template: true)
    let navigationBarTitleColor = UIColor.darkModeColor(hexString: "#555555")
    let navigationShoppingCartImage = UIImage.localImage("cart-icon", template: true)
    let navigationShoppingCartBadgedCountBackgroundColor = UIColor.red.darkModed
    let navigationShoppingCartBadgedCountTextColor = UIColor.modedColor(light: "#ffffff", dark: "#121212")

    // Status bar
    let statusBarStyle: UIStatusBarStyle = .default

    func configureUI() {
        UINavigationBar.appearance().barTintColor = mainThemeColor
        UINavigationBar.appearance().tintColor = navigationBarTitleColor

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: navigationBarTitleColor]
        UINavigationBar.appearance().isTranslucent = false
        
        UITabBar.appearance().barTintColor = self.mainThemeBackgroundColor
        UITabBar.appearance().tintColor = self.mainThemeForegroundColor
        UITabBar.appearance().unselectedItemTintColor = self.mainTextColor
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor : self.mainTextColor,
                                                          .font: self.boldFont(size: 12)],
                                                         for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor : self.mainThemeForegroundColor,
                                                          .font: self.boldFont(size: 12)],
                                                         for: .selected)
        
        UITabBar.appearance().backgroundImage = UIImage.colorForNavBar(self.mainThemeBackgroundColor)
        UITabBar.appearance().shadowImage = UIImage.colorForNavBar(self.hairlineColor)
    }
    
    func configureTabBarUI(tabBar: UITabBar) {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = self.mainThemeBackgroundColor
        appearance.stackedLayoutAppearance.selected.iconColor = self.mainThemeForegroundColor
        appearance.stackedLayoutAppearance.normal.iconColor = self.mainTextColor
        tabBar.standardAppearance = appearance
    }
}
