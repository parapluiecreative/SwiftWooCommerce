//
//  ATCPhoneLoginScreenProtocol.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/8/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCLandingScreenDelegate: class {
    func landingScreenDidLoadView(_ landingScreen: ATCLandingScreenProtocol)
}

protocol ATCPhoneLoginScreenDelegate: class {
    func loginScreenDidLoadView(_ loginScreen: ATCPhoneLoginScreenProtocol)
    func loginScreen(_ loginScreen: ATCPhoneLoginScreenProtocol,
                     didFetchAppleUserWith firstName: String?,
                     lastName: String?,
                     email: String?,
                     password: String)
}

protocol ATCLoginScreenDelegate: class {
    func loginScreenDidLoadView(_ loginScreen: ATCLoginScreenProtocol)
    func loginScreen(_ loginScreen: ATCLoginScreenProtocol,
                     didFetchAppleUserWith firstName: String?,
                     lastName: String?,
                     email: String?,
                     password: String)
}

protocol ATCSignUpScreenDelegate: class {
    func signUpScreenDidLoadView(_ signUpScreen: ATCSignUpScreenProtocol)
}

protocol ATCPhoneSignUpScreenDelegate: class {
    func signUpScreenDidLoadView(_ signUpScreen: ATCPhoneSignUpScreenProtocol)
}

protocol ATCResetPasswordScreenDelegate: class {
    func resetPasswordScreenDidLoadView(_ resetPasswordScreen: ATCResetPasswordScreenProtocol)
}

protocol ATCLandingScreenProtocol {
    var logoImageView: UIImageView! {get}
    var titleLabel: UILabel! {get}
    var subtitleLabel: UILabel! {get}
    var loginButton: UIButton! {get}
    var signUpButton: UIButton! {get}
    var delegate: ATCLandingScreenDelegate? {get set}
}

protocol ATCLoginScreenProtocol {
    var titleLabel: UILabel! {get}
    var contactPointTextField: ATCTextField! {get}
    var passwordTextField: ATCTextField! {get}
    var separatorLabel: UILabel! {get}
    var loginButton: UIButton! {get}
    var facebookButton: UIButton! {get}
    var forgotPasswordButton: UIButton! {get}
    var view: UIView! {get}
    func display(alertController: UIAlertController)
}

protocol ATCPhoneLoginScreenProtocol {
    var titleLabel: UILabel! {get}
    var contactPointTextField: ATCTextField! {get}
    var phoneNumberView: UIView! {get}
    var phoneCountryFlagIcon: UIImageView! {get}
    var phoneCountryFlagBtn: UIButton! {get}
    var phoneCountrySeperatorLabel: UILabel! {get}
    var otpView: UIView! {get}
    var otpStackView: UIStackView! {get}
    var passwordTextField: ATCTextField! {get}
    var phoneNumberTextField: ATCTextField! {get}
    var separatorLabel: UILabel! {get}
    var loginButton: UIButton! {get}
    var facebookButton: UIButton! {get}
    var contactPointButton: UIButton! {get}
    var forgotPasswordButton: UIButton! {get}
    var view: UIView! {get}
    func display(alertController: UIAlertController)
}

protocol ATCSignUpScreenProtocol {
    var titleLabel: UILabel! {get}
    var backButton: UIButton! {get}
    var nameTextField: ATCTextField! {get}
    var phoneNumberTextField: ATCTextField! {get}
    var emailTextField: ATCTextField! {get}
    var passwordTextField: ATCTextField! {get}
    var errorLabel: UILabel! {get}
    var signUpButton: UIButton! {get}
    var view: UIView! {get}
    func display(alertController: UIAlertController)
    func didTapBackButton()
}

protocol ATCPhoneSignUpScreenProtocol {
    var titleLabel: UILabel! {get}
    var backButton: UIButton! {get}
    var firstNameTextField: ATCTextField! {get}
    var lastNameTextField: ATCTextField! {get}
    var phoneNumberTextField: ATCTextField! {get}
    var emailTextField: ATCTextField! {get}
    var passwordTextField: ATCTextField! {get}
    var phoneNumberView: UIView! {get}
    var phoneCountryFlagIcon: UIImageView! {get}
    var phoneCountryFlagBtn: UIButton! {get}
    var phoneCountrySeperatorLabel: UILabel! {get}
    var otpView: UIView! {get}
    var otpStackView: UIStackView! {get}
    var separatorLabel: UILabel! {get}
    var contactPointButton: UIButton! {get}
    var errorLabel: UILabel! {get}
    var signUpButton: UIButton! {get}
    var view: UIView! {get}
    func display(alertController: UIAlertController)
}

protocol ATCResetPasswordScreenProtocol {
    var backButton: UIButton! {get}
    var titleLabel: UILabel! {get}
    var emailTextField: ATCTextField! {get}
    var resetPasswordButton: UIButton! {get}
    var view: UIView! {get}
    func display(alertController: UIAlertController)
}
