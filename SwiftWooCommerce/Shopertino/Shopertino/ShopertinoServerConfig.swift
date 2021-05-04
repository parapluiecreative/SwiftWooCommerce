//
//  ShopertinoServerConfig.swift
//  Shopertino
//
//  Created by Florian Marcu on 4/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ShopertinoServerConfig: ATCOnboardingServerConfigurationProtocol {
    
    var isInstagramIntegrationEnabled: Bool = true
    var isPhoneAuthEnabled: Bool = true
    var appIdentifier: String = "shopertino-swift-ios"
    var isFirebaseAuthEnabled: Bool = true
    var isFirebaseDatabaseEnabled: Bool = false
    var isStripeEnabled: Bool = true
    var wooCommerceStoreURL = "https://www.instakotlin.com/"
    var wooCommerceStoreConsumerPublic = "ck_139a326ad306fb0f82dfa2b767dcc4225eb169d2"
    var wooCommerceStoreConsumerSecret = "cs_356958bd8d2add5e21d3edca49400b43a384f1b5"
}
