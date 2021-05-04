//
//  AppDelegate.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import UIKit
import FirebaseCore

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let serverConfig = ShopertinoServerConfig()
        if (serverConfig.isFirebaseAuthEnabled || serverConfig.isFirebaseDatabaseEnabled) {
            FirebaseApp.configure()
        }

        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        // Configure the UI
        let uiConfig = ShopertinoUIConfiguration()
        uiConfig.configureUI()

        // Window setup
        window = UIWindow(frame: UIScreen.main.bounds)
        let configuration = ATCEcommerceConfiguration(
            stripeEnabled: false,
            applePayEnabled: true
        )
        let loginManager: ATCFirebaseLoginManager? = (serverConfig.isFirebaseDatabaseEnabled ? ATCFirebaseLoginManager(userManager: ATCSocialFirebaseUserManager()) : nil)
        let dsProvider = ShopertinoDataSourceProvider(serverConfig: serverConfig)
        window?.rootViewController = ShopertinoHostViewController(configuration: configuration,
                                                                  uiConfig: uiConfig,
                                                                  loginManager: loginManager,
                                                                  dsProvider: dsProvider,
                                                                  profileManager: ATCFirebaseProfileManager(),
                                                                  serverConfig: serverConfig)
        window?.makeKeyAndVisible()
        return true
    }

}

