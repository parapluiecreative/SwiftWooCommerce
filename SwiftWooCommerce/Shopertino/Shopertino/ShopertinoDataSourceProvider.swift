//
//  ShopertinoDataSourceProvider.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ShopertinoDataSourceProvider: ATCEcommerceDataSourceProvider, ATCAddressesDataSourceProtocol {
    
    func restaurantAdminOrdersDataSource(for viewer: ATCUser) -> ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isFirebaseDatabaseEnabled {
            return ATCFirebaseFirestoreDataSource<ATCOrder>(tableName: "shopertino_orders") {(orders: [ATCOrder]) in
                return orders.sorted(by: { (o1, o2) -> Bool in
                    return o1.createdAt < o2.createdAt
                })
            }
        }
        return ATCGenericLocalDataSource<ATCOrder>(items: MockStore.orders)
    }
    
    let serverConfig: ShopertinoServerConfig
    init(serverConfig: ShopertinoServerConfig) {
        self.serverConfig = serverConfig
    }

    let walkthroughs = [
        ATCWalkthroughModel(title: "Shopertino".localizedInApp, subtitle: "Welcome to Shopertino! Buy our products easily and get access to app only exclusives.".localizedInApp, icon: "shopertino-logo-tinted"),
        ATCWalkthroughModel(title: "Shopping Bag".localizedInApp, subtitle: "Add products to your shopping cart, and check them out later.".localizedInApp, icon: "shopping-bag"),
        ATCWalkthroughModel(title: "Quick Search".localizedInApp, subtitle: "Quickly find the products you like the most.".localizedInApp, icon: "binoculars-icon"),
        ATCWalkthroughModel(title: "Wishlist".localizedInApp, subtitle: "Build a wishlist with your favorite products to buy them later".localizedInApp, icon: "heart-icon"),
        ATCWalkthroughModel(title: "Order Tracking".localizedInApp, subtitle: "Monitor your orders and get updates when something changes.".localizedInApp, icon: "delivery-icon"),
        ATCWalkthroughModel(title: "Notifications".localizedInApp, subtitle: "Get notifications for new products, promotions and discounts.".localizedInApp, icon: "bell-icon"),
        ATCWalkthroughModel(title: "Stripe Payments".localizedInApp, subtitle: "We support all payment options, thanks to Stripe.".localizedInApp, icon: "coins-icon"),
        ATCWalkthroughModel(title: "Apple Pay".localizedInApp, subtitle: "Pay with a single click with Apple Pay.".localizedInApp, icon: "apple-icon"),
    ]

    func onboardingCoordinator(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCOnboardingCoordinatorProtocol {
        
        let landingViewModel = ATCLandingScreenViewModel(imageIcon: "shopertino-logo-tinted",
                                                         title: "Welcome to Shopertino".localizedInApp,
                                                         subtitle: "Shop & get updates on new products, promotions and sales with our mobile app.".localizedInApp,
                                                         loginString: "Log In".localizedInApp,
                                                         signUpString: "Sign Up".localizedInApp)
        
        let phoneLoginViewModel = ATCPhoneLoginScreenViewModel(contactPointField: "E-mail".localizedCore,
                                                               passwordField: "Password".localizedCore,
                                                               title: "Sign In".localizedCore,
                                                               loginString: "Log In".localizedCore,
                                                               sendCodeString: "Send Code".localizedCore,
                                                               submitCodeString: "Submit Code".localizedCore,
                                                               facebookString: "Facebook Login".localizedCore,
                                                               phoneNumberString: "Phone number".localizedCore,
                                                               phoneNumberLoginString: "Login with phone number".localizedCore,
                                                               emailLoginString: "Sign in with E-mail".localizedCore,
                                                               separatorString: "OR".localizedCore,
                                                               contactPoint: .email,
                                                               phoneCodeString: kPhoneVerificationConfig.phoneCode,
                                                               forgotPasswordString: "Forgot Password?".localizedCore)
        
        let loginViewModel = ATCLoginScreenViewModel(contactPointField: "E-mail or phone number".localizedInApp,
                                                     passwordField: "Password".localizedInApp,
                                                     title: "Sign In".localizedInApp,
                                                     loginString: "Log In".localizedInApp,
                                                     facebookString: "Facebook Login".localizedInApp,
                                                     separatorString: "OR".localizedInApp,
                                                     forgotPasswordString: "Forgot Password?".localizedCore)
        
        let phoneSignUpViewModel = ATCPhoneSignUpScreenViewModel(firstNameField: "First Name".localizedCore,
                                                                 lastNameField: "Last Name".localizedCore,
                                                                 phoneField: "Phone Number".localizedCore,
                                                                 emailField: "E-mail Address".localizedCore,
                                                                 passwordField: "Password".localizedCore,
                                                                 title: "Create new account".localizedCore,
                                                                 signUpString: "Sign Up".localizedCore,
                                                                 separatorString: "OR".localizedCore,
                                                                 contactPoint: .email,
                                                                 phoneNumberString: "Phone number".localizedCore,
                                                                 phoneNumberSignUpString: "Sign up with phone number".localizedCore,
                                                                 emailSignUpString: "Sign up with E-mail".localizedCore,
                                                                 sendCodeString: "Send Code".localizedCore,
                                                                 phoneCodeString: kPhoneVerificationConfig.phoneCode,
                                                                 submitCodeString: "Submit Code".localizedCore)

        let signUpViewModel = ATCSignUpScreenViewModel(nameField: "Full Name".localizedInApp,
                                                       phoneField: "Phone Number".localizedInApp,
                                                       emailField: "E-mail Address".localizedInApp,
                                                       passwordField: "Password".localizedInApp,
                                                       title: "Create new account".localizedInApp,
                                                       signUpString: "Sign Up".localizedInApp)
        
        let resetPasswordViewModel = ATCResetPasswordScreenViewModel(title: "Reset Password".localizedCore,
                                                                     emailField: "E-mail Address".localizedCore,
                                                                     resetPasswordString: "Reset My Password".localizedCore)
        
        return ATCClassicOnboardingCoordinator(landingViewModel: landingViewModel,
                                               loginViewModel: loginViewModel,
                                               phoneLoginViewModel: phoneLoginViewModel,
                                               signUpViewModel: signUpViewModel,
                                               phoneSignUpViewModel: phoneSignUpViewModel,
                                               resetPasswordViewModel: resetPasswordViewModel,
                                               uiConfig: ShopertinoOnboardingUIConfiguration(config: uiConfig),
                                               serverConfig: serverConfig,
                                               userManager: ATCSocialFirebaseUserManager())
    }
    
    func walkthroughVC(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCWalkthroughViewController {
        let viewControllers = walkthroughs.map { ATCClassicWalkthroughViewController(model: $0, uiConfig: uiConfig, nibName: "ATCClassicWalkthroughViewController", bundle: nil) }
        return ATCWalkthroughViewController(nibName: "ATCWalkthroughViewController",
                                            bundle: nil,
                                            viewControllers: viewControllers,
                                            uiConfig: uiConfig)
    }

    var categoriesDataSource: ATCGenericCollectionViewControllerDataSource {
        return WooCommerceCategoriesDataSource(apiManager: WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                                                                 key: serverConfig.wooCommerceStoreConsumerPublic,
                                                                                 secret: serverConfig.wooCommerceStoreConsumerSecret))
    }

    var homeProductsDataSource: ATCGenericCollectionViewControllerDataSource {
        return WooCommerceProductsDataSource(apiManager: WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                                                               key: serverConfig.wooCommerceStoreConsumerPublic,
                                                                               secret: serverConfig.wooCommerceStoreConsumerSecret))
    }

    func productsDataSource(for category: Category) -> ATCGenericCollectionViewControllerDataSource {
        return WooCommerceProductsDataSource(apiManager: WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                                                               key: serverConfig.wooCommerceStoreConsumerPublic,
                                                                               secret: serverConfig.wooCommerceStoreConsumerSecret),
                                             categoryId:category.id)
    }

    func ordersDataSource(for user: ATCUser, isPastOrder: Bool) -> ATCGenericCollectionViewControllerDataSource {
        return ATCWooCommerceOrdersDataSource(apiManager: WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                                                                key: serverConfig.wooCommerceStoreConsumerPublic,
                                                                                secret: serverConfig.wooCommerceStoreConsumerSecret),
                                              viewer: user)
    }

    var searchDataSource: ATCGenericSearchViewControllerDataSource {
        return ATCWooCommerceSearchDataSource<Product>(apiManager:
            WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                  key: serverConfig.wooCommerceStoreConsumerPublic,
                                  secret: serverConfig.wooCommerceStoreConsumerSecret))
    }

    var placeOrderManager: ATCPlaceOrderManagerProtocol? {
        return WooCommerceAPIManager(baseURL: serverConfig.wooCommerceStoreURL,
                                     key: serverConfig.wooCommerceStoreConsumerPublic,
                                     secret: serverConfig.wooCommerceStoreConsumerSecret)
    }
    
    var addAuthoredProduct: ATCAddAuthoredProductManagerProtocol? {
        return ATCFirebaseAddAuthoredProductManager(tableName: "shopertino_products")
    }
    
    func authoredProducts(for owner: String?) -> ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isFirebaseDatabaseEnabled {
            let conditions: [String: Any] = ["vendorID": owner ?? ""]
            return ATCFirebaseFirestoreDataSource<Product>(tableName: "shopertino_products",
                                                            conditions: conditions) {(orders: [Product]) in
                                                                return orders.sorted(by: { (o1, o2) -> Bool in
                                                                    return o1.title < o2.title
                                                                })
            }
        }
        return ATCGenericLocalDataSource<Product>(items: [])
    }

    func adminOrdersDataSource(for viewer: ATCUser) -> ATCGenericCollectionViewControllerDataSource {
        if serverConfig.isFirebaseDatabaseEnabled {
            return ATCFirebaseFirestoreDataSource<ATCOrder>(tableName: "shopertino_orders") {(orders: [ATCOrder]) in
                return orders.sorted(by: { (o1, o2) -> Bool in
                    return o1.createdAt < o2.createdAt
                })
            }
        }
        return ATCGenericLocalDataSource<ATCOrder>(items: MockStore.orders)
    }

    func addressDataSource(for user: ATCUser?) -> ATCGenericCollectionViewControllerDataSource? {
        if let userID = user?.uid, !userID.isEmpty {
            let conditions = ["userID": userID]
            return ATCFirebaseAddressesDataSource(tableName: "users",
                                                  conditions: conditions)
        }
        return ATCGenericLocalDataSource<ATCAddress>(items: [])
    }
    
    var featuredCategory = Category(title: "",
                                    id: "34",
//                                    id: "Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzMyNTM5ODY5MjM2",
                                    imageURLString: "")
    var gridProductsCategory = Category(title: "",
                                    id: "35",
//                                     id: "Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzM1MDQ3NDczMjA0",
                                    imageURLString: "")
    var mainCarouselCategory = Category(title: "",
                                        id: "38",
//                                        id: "Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzMyNTM5ODY5MjM2",
                                        imageURLString: "")
}
