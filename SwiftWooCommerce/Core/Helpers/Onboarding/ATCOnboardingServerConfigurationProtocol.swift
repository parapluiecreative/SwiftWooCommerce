//
//  ATCOnboardingServerConfigurationProtocol.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/18/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCOnboardingServerConfigurationProtocol {
    var isFirebaseAuthEnabled: Bool {get}
    var appIdentifier: String {get}
    var isFirebaseDatabaseEnabled: Bool {get}
    var isInstagramIntegrationEnabled: Bool {get}
    var isPhoneAuthEnabled: Bool {get}
    var googleApiKey: String {get}
    var role: ATCRole {get}
    var locationFetcherEnabled: Bool {get}
}

extension ATCOnboardingServerConfigurationProtocol {
    var role : ATCRole { get{ return .user } set{} }
    var googleApiKey : String { get{ return "" } set{} }
    var locationFetcherEnabled: Bool { get{ return false } set{} }
}
