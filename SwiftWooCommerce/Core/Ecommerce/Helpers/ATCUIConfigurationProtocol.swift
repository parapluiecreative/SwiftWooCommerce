//
//  UIConfiguration.swift
//  ShoppingApp
//
//  Created by Florian Marcu on 8/29/17.
//  Copyright © 2017 iOS App Templates. All rights reserved.
//

import UIKit

protocol ATCUIConfigurationProtocol {
    // General
    var mainThemeColor: UIColor {get}
    var regularSmallSizeFont: UIFont {get}
    var regularMediumSizeFont: UIFont {get}
    var regularLargeSizeFont: UIFont {get}
    var mainButtonBackgroundColor: UIColor {get}
    
    var subtitleLabelColor: UIColor {get}
    
    // Menu
    var menuItemFont: UIFont {get}
    var menuTintColor: UIColor {get}
    var menuHomeImage: UIImage {get}
    var menuOrdersImage: UIImage {get}
    var menuSearchImage: UIImage {get}
    var menuRestaurantMenuImage: UIImage {get}
    var menuReservationMenuImage: UIImage {get}
    var menuItemHeight: CGFloat {get}
    
    // Navigation
    var navigationMenuImage: UIImage {get}
    var navigationBarTitleColor: UIColor {get}
    var navigationShoppingCartImage: UIImage {get}
    var navigationShoppingCartBadgedCountBackgroundColor: UIColor {get}
    var navigationShoppingCartBadgedCountTextColor: UIColor {get}
    
    // Status bar
    var statusBarStyle: UIStatusBarStyle {get}
    
    // Home screen
    var homeScreenTitle: String {get}
    var categoriesTitle: String {get}
    var homeScreenStoriesFont: UIFont {get}
    
    // Tab bar
    var tabBarBarTintColor: UIColor {get}
    var homeTabBarItemTitle: String {get}
    var categoriesTabBarItemTitle: String {get}
    var cartTabBarItemTitle: String {get}
    
    // Category screen
    var categoryScreenColorAlpha: CGFloat {get}
    var categoryScreenTitleLabelColor: UIColor {get}
    var categoryScreenTitleLabelAlpha: CGFloat {get}
    var categoryScreenCellHeight: CGFloat {get}
    var categoryScreenBackgroundColor: UIColor {get}
    var categoryScreenCellPadding: CGFloat {get}
    var categoryScreenTitleFont: UIFont {get}
    
    // Product list screen
    var productScreenCellHeight: CGFloat {get}
    var productScreenCellWidth: CGFloat {get}
    var productScreenBackgroundColor: UIColor {get}
    var productScreenTitleFont: UIFont {get}
    var productScreenPriceFont: UIFont {get}
    var productScreenDescriptionFont: UIFont {get}
    var productScreenImageViewBorderColor: UIColor {get}
    var productScreenDescriptionColor: UIColor {get}
    var productScreenTextColor: UIColor {get}
    
    // Product Details screen
    var productDetailsScreenImageBackground: UIColor {get}
    var productDetailsCollectionViewCellSize: CGSize {get}
    var productDetailsTitleFont: UIFont {get}
    var productDetailsPriceBorderColor: UIColor {get}
    var productDetailsTextColor: UIColor {get}
    var productDetailsPriceFont: UIFont {get}
    var productDetailsAddToCartButtonFont: UIFont {get}
    var productDetailsAddToCartButtonBgColor: UIColor {get}
    var productDetailsDescriptionFont: UIFont {get}
    var productDetailsStepperierFont: UIFont {get}
    
    // Cart Screen
    var cartScreenCellHeight: CGFloat {get}
    var cartScreenFooterCellHeight: CGFloat {get}
    var cartScreenBackgroundColor: UIColor {get}
    var cartScreenTitle: String {get}
    var cartScreenLabelColor: UIColor {get}
    var cartScreenCountLabelColor: UIColor {get}
    var cartScreenCountBorderColor: UIColor {get}
    var cartScreenTitleFont: UIFont {get}
    var cartScreenPriceFont: UIFont {get}
    var cartScreenCountFont: UIFont {get}
    var cartScreenFooterPriceFont: UIFont {get}
    var cartScreenFooterTotalPriceTextFont: UIFont {get}
    var cartScreenFooterPriceColor: UIColor {get}
    var cartScreenFooterTotalPriceTextColor: UIColor {get}
    var cartScreenCheckoutButtonFont: UIFont {get}
    var cartScreenCheckoutButtonHeight: CGFloat {get}
    var cartScreenCheckoutButtonTitle: String {get}
    var cartScreenCheckoutButtonBackgroundColor: UIColor {get}
    var cartScreenCheckoutButtonTextColor: UIColor {get}
    
    // Orders Screen
    var ordersScreenCartItemCellHeight: CGFloat {get}
    var ordersScreenButtonFont: UIFont {get}
    var ordersScreenButtonHeight: CGFloat {get}
    var ordersScreenFooterPriceFont: UIFont {get}
    
    func configureUI()
}
