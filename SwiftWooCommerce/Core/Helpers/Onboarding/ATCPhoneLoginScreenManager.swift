//
//  ATCPhoneLoginScreenManager.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/8/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import UIKit

protocol ATCPhoneLoginScreenManagerDelegate: class {
    func loginManagerDidCompleteLogin(_ loginManager: ATCPhoneLoginScreenManager, user: ATCUser?)
    func phoneLoginManagerDidTapCountryFlagButton(_ loginManager: ATCPhoneLoginScreenManager)
    func tapPhoneLoginForgotPasswordButton(_ loginManager: ATCPhoneLoginScreenManager)
}

class ATCPhoneLoginScreenManager: NSObject, ATCPhoneLoginScreenDelegate {
    let loginScreen: ATCPhoneLoginScreenProtocol
    var viewModel: ATCPhoneLoginScreenViewModel
    let uiConfig: ATCOnboardingConfigurationProtocol
    let serverConfig: ATCOnboardingServerConfigurationProtocol
    let userManager: ATCSocialUserManagerProtocol?
    let loginManager: ATCFirebaseLoginManager

    weak var delegate: ATCPhoneLoginScreenManagerDelegate?

    private let readPermissions: [String] = ["public_profile",
                                             "email"]

    init(loginScreen: ATCPhoneLoginScreenProtocol,
         viewModel: ATCPhoneLoginScreenViewModel,
         uiConfig: ATCOnboardingConfigurationProtocol,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         userManager: ATCSocialUserManagerProtocol?) {
        self.loginScreen = loginScreen
        self.viewModel = viewModel
        self.uiConfig = uiConfig
        self.serverConfig = serverConfig
        self.userManager = userManager
        self.loginManager = ATCFirebaseLoginManager(userManager: userManager)
    }

    var country: Country? {
        didSet {
            if let phoneCountryFlagIcon = loginScreen.phoneCountryFlagIcon {
                phoneCountryFlagIcon.image = country?.flag
            }
        }
    }
    
    func loginScreenDidLoadView(_ loginScreen: ATCPhoneLoginScreenProtocol) {
        if let titleLabel = loginScreen.titleLabel {
            titleLabel.font = uiConfig.titleFont
            titleLabel.text = viewModel.title
            titleLabel.textColor = uiConfig.titleColor
        }

        let isLoginWithEmail = viewModel.contactPoint == .email

        if let cpField = loginScreen.contactPointTextField {
            cpField.configure(color: uiConfig.textFieldColor,
                              font: uiConfig.textFieldFont,
                              cornerRadius: 55/2,
                              borderColor: uiConfig.textFieldBorderColor,
                              backgroundColor: uiConfig.textFieldBackgroundColor,
                              borderWidth: 1.0)
            cpField.placeholder = viewModel.contactPointField
            cpField.textContentType = .emailAddress
            cpField.clipsToBounds = true
            cpField.isHidden = !isLoginWithEmail
        }

        if let phoneNumberField = loginScreen.phoneNumberTextField, let phoneNumberView = loginScreen.phoneNumberView, let phoneCountrySeperatorLabel = loginScreen.phoneCountrySeperatorLabel {
            phoneNumberField.configure(color: uiConfig.textFieldColor,
                              font: uiConfig.textFieldFont,
                              cornerRadius: 0,
                              backgroundColor: .clear)
            phoneNumberField.placeholder = viewModel.phoneNumberString
            phoneNumberField.clipsToBounds = true
            phoneNumberView.addBorder(borderWidth: 1.0, borderColor: uiConfig.textFieldBorderColor, cornerRadius: 55/2)
            phoneNumberView.isHidden = isLoginWithEmail
            phoneCountrySeperatorLabel.backgroundColor = uiConfig.textFieldBorderColor
        }

        if let phoneCountryFlagBtn = loginScreen.phoneCountryFlagBtn, let phoneCountryFlagIcon = loginScreen.phoneCountryFlagIcon {
            phoneCountryFlagBtn.addTarget(self, action: #selector(didTapCountryFlagButton), for: .touchUpInside)
            phoneCountryFlagIcon.image = kPhoneVerificationConfig.countryFlag
        }

        if let passwordField = loginScreen.passwordTextField {
            passwordField.configure(color: uiConfig.textFieldColor,
                                    font: uiConfig.textFieldFont,
                                    cornerRadius: 55/2,
                                    borderColor: uiConfig.textFieldBorderColor,
                                    backgroundColor: uiConfig.textFieldBackgroundColor,
                                    borderWidth: 1.0)
            passwordField.placeholder = viewModel.passwordField
            passwordField.isSecureTextEntry = true
            passwordField.textContentType = .emailAddress
            passwordField.clipsToBounds = true
            passwordField.isHidden = !isLoginWithEmail
        }

        if let separatorLabel = loginScreen.separatorLabel {
            separatorLabel.font = uiConfig.separatorFont
            separatorLabel.textColor = uiConfig.separatorColor
            separatorLabel.text = viewModel.separatorString
        }

        if let loginButton = loginScreen.loginButton {
            loginButton.setTitle(viewModel.loginString, for: .normal)
            loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
            loginButton.configure(color: uiConfig.loginButtonTextColor,
                                  font: uiConfig.loginButtonFont,
                                  cornerRadius: 8,
                                  backgroundColor: uiConfig.loginButtonBackgroundColor)
        }

        if let facebookButton = loginScreen.facebookButton {
            facebookButton.setTitle(viewModel.facebookString, for: .normal)
            facebookButton.addTarget(self, action: #selector(didTapFacebookButton), for: .touchUpInside)
            facebookButton.configure(color: uiConfig.loginButtonTextColor,
                                     font: UIFont.systemFont(ofSize: 22, weight: .medium),
                                     cornerRadius: 8,
                                     backgroundColor: UIColor(hexString: "#334D92"))
        }
        
        if let contactPointButton = loginScreen.contactPointButton {
            contactPointButton.setTitle(viewModel.phoneNumberLoginString, for: .normal)
            contactPointButton.addTarget(self, action: #selector(didTapContactPointButton), for: .touchUpInside)
            contactPointButton.setTitleColor(uiConfig.titleColor, for: .normal)
            contactPointButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        if let forgotPasswordButton = loginScreen.forgotPasswordButton {
            forgotPasswordButton.setTitle(viewModel.forgotPasswordString, for: .normal)
            forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPasswordButton), for: .touchUpInside)
            forgotPasswordButton.setTitleColor(uiConfig.titleColor, for: .normal)
            forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        }
        
        if let otpView = loginScreen.otpView {
            otpView.backgroundColor = uiConfig.otpTextFieldBorderColor
            otpView.addBorder(borderWidth: 1.0,
                              borderColor: uiConfig.otpTextFieldBorderColor,
                              cornerRadius: 55/2)
            otpView.isHidden = true
        }
        
        if let otpStackView = loginScreen.otpStackView {
            otpStackView.spacing = 1.0
            for otpIndex in 0..<kPhoneVerificationConfig.otpCount {
                let textField = UITextField()
                textField.delegate = self
                textField.textAlignment = .center
                textField.tag = otpIndex
                textField.backgroundColor = uiConfig.otpTextFieldBackgroundColor
                textField.tintColor = .clear
                textField.keyboardType = .numberPad
                otpStackView.addArrangedSubview(textField)
            }
        }
    }

    func loginScreen(_ loginScreen: ATCPhoneLoginScreenProtocol,
                     didFetchAppleUserWith firstName: String?,
                     lastName: String?,
                     email: String?,
                     password: String) {
        // Currently, Firebase doesn't support Apple Sign In
        if serverConfig.isFirebaseAuthEnabled {
            print("error - Firebase doesn't support Apple Signin")
        }
        guard let email = email else { return }
        // For Apple Signin, we use the token as password
        ATCFirebaseLoginManager.signIn(email: email, pass: password) { (atcUser, message) in
            if let message = message {
                self.showLoginError(message)
                return
            }
            guard let atcUser = atcUser, let uid = atcUser.uid else {
                self.showLoginError()
                return
            }
            self.loginManager.saveUserToServerIfNeeded(user: atcUser,
                                                       appIdentifier: self.serverConfig.appIdentifier)
            self.userManager?.fetchUser(userID: uid, completion: {(user, error) in
                self.delegate?.loginManagerDidCompleteLogin(self, user: user ?? atcUser)
            })
        }
    }

    @objc func didTapCountryFlagButton() {
        self.delegate?.phoneLoginManagerDidTapCountryFlagButton(self)
    }
    
    @objc func didTapForgotPasswordButton() {
        self.delegate?.tapPhoneLoginForgotPasswordButton(self)
    }
    
    @objc func didTapContactPointButton() {
        if let contactPointButton = loginScreen.contactPointButton, let cpField = loginScreen.contactPointTextField, let passwordField = loginScreen.passwordTextField, let phoneNumberView = loginScreen.phoneNumberView, let loginButton = loginScreen.loginButton, let otpView = loginScreen.otpView {
            let isLoginWithEmail = viewModel.contactPoint == .email
            cpField.isHidden = isLoginWithEmail
            passwordField.isHidden = isLoginWithEmail
            phoneNumberView.isHidden = !isLoginWithEmail
            otpView.isHidden = true
            if isLoginWithEmail {
                contactPointButton.setTitle(viewModel.emailLoginString, for: .normal)
                loginButton.setTitle(viewModel.sendCodeString, for: .normal)
                viewModel.contactPoint = ContactPoint.phone
            } else if viewModel.contactPoint == .phone || viewModel.contactPoint == .phoneWithOtp {
                contactPointButton.setTitle(viewModel.phoneNumberLoginString, for: .normal)
                loginButton.setTitle(viewModel.loginString, for: .normal)
                if viewModel.contactPoint == .phoneWithOtp {
                    if let otpStackView = loginScreen.otpStackView {
                        for view in otpStackView.subviews {
                            if let textField = view as? UITextField {
                                textField.text = ""
                            }
                        }
                    }
                }
                viewModel.contactPoint = ContactPoint.email
            }
        }
    }
    
    @objc func didTapLoginButton() {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
        if serverConfig.isFirebaseAuthEnabled {
            if viewModel.contactPoint == .phone {
                if let phoneCodeString = viewModel.phoneCodeString, let phoneNumber = loginScreen.phoneNumberTextField.text, !phoneNumber.isEmpty {
                    let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                    hud.show(in: loginScreen.view)
                    PhoneAuthProvider.provider().verifyPhoneNumber(phoneCodeString + phoneNumber, uiDelegate: nil) {[weak self] (verificationID, error) in
                        hud.dismiss()
                        if let error = error {
                            self?.showLoginError(error.localizedDescription)
                        } else {
                            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                            self?.viewModel.contactPoint = .phoneWithOtp
                            if let otpView = self?.loginScreen.otpView {
                                otpView.isHidden = false
                            }
                            if let phoneNumberView = self?.loginScreen.phoneNumberView {
                                phoneNumberView.isHidden = true
                            }
                            if let loginButton = self?.loginScreen.loginButton {
                                loginButton.setTitle(self?.viewModel.submitCodeString, for: .normal)
                            }
                        }
                    }
                } else {
                    self.showLoginError()
                }
                return
            } else if viewModel.contactPoint == .phoneWithOtp {
                var verificationCode: String = ""
                if let otpStackView = loginScreen.otpStackView {
                    for view in otpStackView.subviews {
                        if let textField = view as? UITextField {
                            verificationCode += textField.text!
                        }
                    }
                }
                
                if !verificationCode.isEmpty {
                    let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                    hud.show(in: loginScreen.view)
                    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
                    let credential = PhoneAuthProvider.provider().credential(
                        withVerificationID: verificationID,
                        verificationCode: verificationCode)
                    Auth.auth().signIn(with: credential) {[weak self] (dataResult, error) in
                        hud.dismiss()
                        if let strongSelf = self, let user = dataResult?.user {
                            let atcUser = ATCUser(uid: user.uid,
                                                  firstName: user.displayName ?? "",
                                                  lastName: "",
                                                  avatarURL: user.photoURL?.absoluteString ?? "",
                                                  email: user.email ?? "")
                            strongSelf.userManager?.fetchUser(userID: user.uid, completion: {[weak strongSelf] (user, error) in
                                if let error = error {
                                    self?.showLoginError(error.localizedDescription)
                                } else if let secondStrongSelf = strongSelf {
                                    secondStrongSelf.delegate?.loginManagerDidCompleteLogin(secondStrongSelf, user: user ?? atcUser)
                                    secondStrongSelf.viewModel.contactPoint = .phone
                                    if let otpView = secondStrongSelf.loginScreen.otpView {
                                        otpView.isHidden = true
                                    }
                                    if let phoneNumberView = secondStrongSelf.loginScreen.phoneNumberView {
                                        phoneNumberView.isHidden = false
                                    }
                                    if let loginButton = self?.loginScreen.loginButton {
                                        loginButton.setTitle(self?.viewModel.sendCodeString, for: .normal)
                                    }
                                }
                            })
                        } else {
                            self?.showLoginError()
                        }
                    }
                } else {
                    self.showLoginError()
                }
                return
            } else {
                if let email = loginScreen.contactPointTextField.text,
                    let password = loginScreen.passwordTextField.text {
                    let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                    hud.show(in: loginScreen.view)
                    Auth.auth().signIn(withEmail: email, password: password) {[weak self] (dataResult, error) in
                        hud.dismiss()
                        if let strongSelf = self, let user = dataResult?.user {
                            let atcUser = ATCUser(uid: user.uid,
                                                  firstName: user.displayName ?? "",
                                                  lastName: "",
                                                  avatarURL: user.photoURL?.absoluteString ?? "",
                                                  email: user.email ?? "")
                            strongSelf.userManager?.fetchUser(userID: user.uid, completion: {[weak strongSelf] (user, error) in
                                if let error = error {
                                    self?.showLoginError(error.localizedDescription)
                                } else if let secondStrongSelf = strongSelf {
                                    secondStrongSelf.delegate?.loginManagerDidCompleteLogin(secondStrongSelf, user: user ?? atcUser)
                                }
                            })
                        } else {
                            self?.showLoginError()
                        }
                    }
                } else {
                    self.showLoginError()
                }
                return
            }
        }
        self.delegate?.loginManagerDidCompleteLogin(self, user: nil)
    }

    @objc func didTapFacebookButton() {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
        if let loginScreen = loginScreen as? UIViewController {
            let loginManager = LoginManager()
            loginManager.logIn(permissions: readPermissions, from: loginScreen) { (result, error) in
                if (result?.token != nil) {
                    self.didLoginWithFacebook()
                }
            }
        }
    }

    private func didLoginWithFacebook() {
        //  Successful log in with Facebook
        if let accessToken = AccessToken.current {
            // If Firebase enabled, we log the user into Firebase
            if serverConfig.isFirebaseAuthEnabled {
                let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                hud.show(in: loginScreen.view)
                ATCFirebaseLoginManager.login(credential: FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)) {[weak self] (atcUser) in
                    hud.dismiss()
                    if let user = atcUser, let strongSelf = self {
                        strongSelf.loginManager.saveUserToServerIfNeeded(user: user, appIdentifier: strongSelf.serverConfig.appIdentifier)
                        strongSelf.delegate?.loginManagerDidCompleteLogin(strongSelf, user: user)
                    } else {
                        // Facebook succeeded, but Firebase failed
                        self?.showLoginError()
                    }
                }
            } else {
                let facebookAPIManager = ATCFacebookAPIManager(accessToken: accessToken)
                let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                hud.show(in: loginScreen.view)
                facebookAPIManager.requestFacebookUser(completion: {[weak self] (facebookUser) in
                    hud.dismiss()
                    if let strongSelf = self, let email = facebookUser?.email {
                        let atcUser = ATCUser(uid: facebookUser?.id ?? "",
                                              firstName: facebookUser?.firstName ?? "",
                                              lastName: facebookUser?.lastName ?? "",
                                              avatarURL: facebookUser?.profilePicture ?? "",
                                              email: email)
                        strongSelf.delegate?.loginManagerDidCompleteLogin(strongSelf, user: atcUser)
                    } else {
                        self?.showLoginError()
                    }
                })
            }
            return
        }
        self.showLoginError()
    }

    fileprivate func showLoginError(_ title: String? = "The login credentials are invalid. Please try again".localizedCore) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: nil))
        self.loginScreen.display(alertController: alert)
    }
}

extension ATCPhoneLoginScreenManager: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let otpStackView = self.loginScreen.otpStackView {
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    var fillTextField = otpStackView.subviews.filter { (view) -> Bool in
                        if let textField = view as? UITextField, let text = textField.text {
                            if !text.isEmpty {
                                return true
                            }
                        }
                        return false
                    }
                    if let textField = fillTextField.last as? UITextField {
                        textField.text = ""
                    }
                    fillTextField.removeLast()
                    if let textField = fillTextField.last as? UITextField {
                        textField.becomeFirstResponder()
                    }
                } else {
                    for view in otpStackView.subviews {
                        if let textField = view as? UITextField, let text = textField.text {
                            if text.isEmpty {
                                textField.text = string
                                textField.becomeFirstResponder()
                                return false
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}
