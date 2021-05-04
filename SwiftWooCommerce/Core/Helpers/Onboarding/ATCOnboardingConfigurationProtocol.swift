//
//  ATCOnboardingConfigurationProtocol.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/8/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCOnboardingConfigurationProtocol {
    var backgroundColor: UIColor {get}
    var titleColor: UIColor {get}
    var titleFont: UIFont {get}
    var logoTintColor: UIColor? {get}

    var subtitleColor: UIColor {get}
    var subtitleFont: UIFont {get}

    var loginButtonFont: UIFont {get}
    var loginButtonBackgroundColor: UIColor {get}
    var loginButtonTextColor: UIColor {get}

    var signUpButtonFont: UIFont {get}
    var signUpButtonBackgroundColor: UIColor {get}
    var signUpButtonTextColor: UIColor {get}
    var signUpButtonBorderColor: UIColor {get}

    var separatorFont: UIFont {get}
    var separatorColor: UIColor {get}

    var textFieldColor: UIColor {get}
    var textFieldFont: UIFont {get}
    var textFieldBorderColor: UIColor {get}
    var textFieldBackgroundColor: UIColor {get}

    var signUpTextFieldFont: UIFont {get}
    var signUpScreenButtonFont: UIFont {get}
    
    var otpTextFieldBackgroundColor: UIColor {get}
    var otpTextFieldBorderColor: UIColor {get}
}
