//
//  ATCPhoneSignUpScreenManager.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseAuth
import UIKit

protocol ATCPhoneSignUpScreenManagerDelegate: class {
    func signUpManagerDidCompleteSignUp(_ signUpManager: ATCPhoneSignUpScreenManager, user: ATCUser?)
    func tapPhoneSignUpCountryFlagButton()
}

class ATCPhoneSignUpScreenManager: NSObject, ATCPhoneSignUpScreenDelegate {
    let signUpScreen: ATCPhoneSignUpScreenProtocol
    var viewModel: ATCPhoneSignUpScreenViewModel
    let uiConfig: ATCOnboardingConfigurationProtocol
    let serverConfig: ATCOnboardingServerConfigurationProtocol
    let firebaseLoginManager: ATCFirebaseLoginManager?

    weak var delegate: ATCPhoneSignUpScreenManagerDelegate?

    var country: Country? {
        didSet {
            if let phoneCountryFlagIcon = signUpScreen.phoneCountryFlagIcon {
                phoneCountryFlagIcon.image = country?.flag
            }
        }
    }
    
    init(signUpScreen: ATCPhoneSignUpScreenProtocol,
         viewModel: ATCPhoneSignUpScreenViewModel,
         uiConfig: ATCOnboardingConfigurationProtocol,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         userManager: ATCSocialUserManagerProtocol?) {
        self.signUpScreen = signUpScreen
        self.viewModel = viewModel
        self.uiConfig = uiConfig
        self.serverConfig = serverConfig
        self.firebaseLoginManager = serverConfig.isFirebaseAuthEnabled ? ATCFirebaseLoginManager(userManager: userManager) : nil
        super.init()
    }

    func signUpScreenDidLoadView(_ signUpScreen: ATCPhoneSignUpScreenProtocol) {
        if let titleLabel = signUpScreen.titleLabel {
            titleLabel.font = uiConfig.titleFont
            titleLabel.text = viewModel.title
            titleLabel.textColor = uiConfig.titleColor
        }

        if let firstNameField = signUpScreen.firstNameTextField {
            firstNameField.configure(color: uiConfig.textFieldColor,
                                font: uiConfig.signUpTextFieldFont,
                                cornerRadius: 40/2,
                                borderColor: uiConfig.textFieldBorderColor,
                                backgroundColor: uiConfig.textFieldBackgroundColor,
                                borderWidth: 1.0)
            firstNameField.placeholder = viewModel.firstNameField
            firstNameField.clipsToBounds = true
        }

        if let lastNameField = signUpScreen.lastNameTextField {
            lastNameField.configure(color: uiConfig.textFieldColor,
                                font: uiConfig.signUpTextFieldFont,
                                cornerRadius: 40/2,
                                borderColor: uiConfig.textFieldBorderColor,
                                backgroundColor: uiConfig.textFieldBackgroundColor,
                                borderWidth: 1.0)
            lastNameField.placeholder = viewModel.lastNameField
            lastNameField.clipsToBounds = true
        }

        if let separatorLabel = signUpScreen.separatorLabel {
            separatorLabel.font = uiConfig.separatorFont
            separatorLabel.textColor = uiConfig.separatorColor
            separatorLabel.text = viewModel.separatorString
        }

        if let emailField = signUpScreen.emailTextField {
            emailField.configure(color: uiConfig.textFieldColor,
                                font: uiConfig.signUpTextFieldFont,
                                cornerRadius: 40/2,
                                borderColor: uiConfig.textFieldBorderColor,
                                backgroundColor: uiConfig.textFieldBackgroundColor,
                                borderWidth: 1.0)
            emailField.placeholder = viewModel.emailField
            emailField.clipsToBounds = true
        }

        let isSignUpWithEmail = viewModel.contactPoint == .email

        if let phoneNumberField = signUpScreen.phoneNumberTextField, let phoneNumberView = signUpScreen.phoneNumberView, let phoneCountrySeperatorLabel = signUpScreen.phoneCountrySeperatorLabel {
            phoneNumberField.configure(color: uiConfig.textFieldColor,
                              font: uiConfig.signUpTextFieldFont,
                              cornerRadius: 0,
                              backgroundColor: .clear)
            phoneNumberField.placeholder = viewModel.phoneNumberString
            phoneNumberField.clipsToBounds = true
            phoneNumberView.addBorder(borderWidth: 1.0,
                                      borderColor: uiConfig.textFieldBorderColor,
                                      cornerRadius: 40/2)
            phoneNumberView.isHidden = isSignUpWithEmail
            phoneCountrySeperatorLabel.backgroundColor = uiConfig.textFieldBorderColor
        }

        if let phoneCountryFlagBtn = signUpScreen.phoneCountryFlagBtn, let phoneCountryFlagIcon = signUpScreen.phoneCountryFlagIcon {
            phoneCountryFlagBtn.addTarget(self, action: #selector(didTapCountryFlagButton), for: .touchUpInside)
            phoneCountryFlagIcon.image = kPhoneVerificationConfig.countryFlag
        }

        if let passwordField = signUpScreen.passwordTextField {
            passwordField.configure(color: uiConfig.textFieldColor,
                                    font: uiConfig.signUpTextFieldFont,
                                    cornerRadius: 40/2,
                                    borderColor: uiConfig.textFieldBorderColor,
                                    backgroundColor: uiConfig.textFieldBackgroundColor,
                                    borderWidth: 1.0)
            passwordField.placeholder = viewModel.passwordField
            passwordField.isSecureTextEntry = true
            passwordField.clipsToBounds = true
        }
        
        if let signUpButton = signUpScreen.signUpButton {
            signUpButton.setTitle(viewModel.signUpString, for: .normal)
            signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
            signUpButton.configure(color: uiConfig.loginButtonTextColor,
                                     font: uiConfig.signUpScreenButtonFont,
                                     cornerRadius: 40/2,
                                     backgroundColor: UIColor(hexString: "#334D92"))
        }
        
        if let contactPointButton = signUpScreen.contactPointButton {
            contactPointButton.setTitle(viewModel.phoneNumberSignUpString, for: .normal)
            contactPointButton.addTarget(self, action: #selector(didTapContactPointButton), for: .touchUpInside)
            contactPointButton.setTitleColor(uiConfig.titleColor, for: .normal)
            contactPointButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        if let otpView = signUpScreen.otpView {
            otpView.backgroundColor = uiConfig.otpTextFieldBorderColor
            otpView.addBorder(borderWidth: 1.0,
                              borderColor: uiConfig.otpTextFieldBorderColor,
                              cornerRadius: 40/2)
            otpView.isHidden = true
        }
        
        if let otpStackView = signUpScreen.otpStackView {
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

    @objc func didTapContactPointButton() {
        if let contactPointButton = signUpScreen.contactPointButton, let cpField = signUpScreen.emailTextField, let passwordField = signUpScreen.passwordTextField, let phoneNumberView = signUpScreen.phoneNumberView, let signUpButton = signUpScreen.signUpButton, let otpView = signUpScreen.otpView {
            let isSignUpWithEmail = viewModel.contactPoint == .email
            cpField.isHidden = isSignUpWithEmail
            passwordField.isHidden = isSignUpWithEmail
            phoneNumberView.isHidden = !isSignUpWithEmail
            otpView.isHidden = true
            if isSignUpWithEmail {
                contactPointButton.setTitle(viewModel.emailSignUpString, for: .normal)
                signUpButton.setTitle(viewModel.sendCodeString, for: .normal)
                viewModel.contactPoint = ContactPoint.phone
            } else if viewModel.contactPoint == .phone || viewModel.contactPoint == .phoneWithOtp {
                contactPointButton.setTitle(viewModel.phoneNumberSignUpString, for: .normal)
                signUpButton.setTitle(viewModel.signUpString, for: .normal)
                if viewModel.contactPoint == .phoneWithOtp {
                    if let otpStackView = signUpScreen.otpStackView {
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
    
    @objc func didTapCountryFlagButton() {
        self.delegate?.tapPhoneSignUpCountryFlagButton()
    }
    
    @objc func didTapSignUpButton() {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
        if serverConfig.isFirebaseAuthEnabled {
            if viewModel.contactPoint == .phone {
                if let phoneCodeString = viewModel.phoneCodeString, let phoneNumber = signUpScreen.phoneNumberTextField.text, !phoneNumber.isEmpty {
                    let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                    hud.show(in: signUpScreen.view)
                    PhoneAuthProvider.provider().verifyPhoneNumber(phoneCodeString + phoneNumber, uiDelegate: nil) {[weak self] (verificationID, error) in
                        hud.dismiss()
                        if let error = error {
                            self?.showSignUpError(text: error.localizedDescription)
                        } else {
                            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                            self?.viewModel.contactPoint = .phoneWithOtp
                            if let otpView = self?.signUpScreen.otpView {
                                otpView.isHidden = false
                            }
                            if let phoneNumberView = self?.signUpScreen.phoneNumberView {
                                phoneNumberView.isHidden = true
                            }
                            if let signUpButton = self?.signUpScreen.signUpButton {
                                signUpButton.setTitle(self?.viewModel.submitCodeString, for: .normal)
                            }
                        }
                    }
                } else {
                    self.showGenericSignUpError()
                }
                return
            } else if viewModel.contactPoint == .phoneWithOtp {
                var verificationCode: String = ""
                if let otpStackView = signUpScreen.otpStackView {
                    for view in otpStackView.subviews {
                        if let textField = view as? UITextField {
                            verificationCode += textField.text!
                        }
                    }
                }
                
                if !verificationCode.isEmpty {
                    let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                    hud.show(in: signUpScreen.view)
                    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
                    let credential = PhoneAuthProvider.provider().credential(
                        withVerificationID: verificationID,
                        verificationCode: verificationCode)
                    Auth.auth().signIn(with: credential) {[weak self] (dataResult, error) in
                        hud.dismiss()
                        if let user = dataResult?.user {
                            if let strongSelf = self {
                                let atcUser = ATCUser(uid: user.uid,
                                                      firstName: user.displayName ?? strongSelf.signUpScreen.firstNameTextField.text ?? "",
                                                      lastName: user.displayName ?? strongSelf.signUpScreen.lastNameTextField.text ?? "",
                                                      avatarURL: user.photoURL?.absoluteString ?? "",
                                                      email: user.email ?? "",
                                                      phoneNumber: user.phoneNumber ?? "",
                                                      role: strongSelf.serverConfig.role.rawValue)
                                strongSelf.firebaseLoginManager?.saveUserToServerIfNeeded(user: atcUser, appIdentifier: strongSelf.serverConfig.appIdentifier)
                                strongSelf.delegate?.signUpManagerDidCompleteSignUp(strongSelf, user: atcUser)
                                strongSelf.viewModel.contactPoint = .phone
                                if let otpView = strongSelf.signUpScreen.otpView {
                                    otpView.isHidden = true
                                }
                                if let phoneNumberView = strongSelf.signUpScreen.phoneNumberView {
                                    phoneNumberView.isHidden = false
                                }
                                if let signUpButton = strongSelf.signUpScreen.signUpButton {
                                    signUpButton.setTitle(strongSelf.viewModel.sendCodeString, for: .normal)
                                }
                            }
                        } else {
                            self?.showSignUpError(text: error?.localizedDescription ?? "There was an error. Please try again later".localizedCore)
                        }
                    }
                } else {
                    self.showGenericSignUpError()
                }
                return
            } else {
                if let email = signUpScreen.emailTextField.text,
                    let password = signUpScreen.passwordTextField.text,
                    let firstName = signUpScreen.firstNameTextField.text {
                    if (!isValid(email: email, pass: password, firstName: firstName)) {
                        return
                    }
                    let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                    hud.show(in: signUpScreen.view)
                    Auth.auth().createUser(withEmail: email, password: password) {[weak self] (authResult, error) in
                        hud.dismiss()
                        if let user = authResult?.user {
                            if let strongSelf = self {
                                let atcUser = ATCUser(uid: user.uid,
                                                      firstName: user.displayName ?? strongSelf.signUpScreen.firstNameTextField.text ?? "",
                                                      lastName: user.displayName ?? strongSelf.signUpScreen.lastNameTextField.text ?? "",
                                                      avatarURL: user.photoURL?.absoluteString ?? "",
                                                      email: user.email ?? "",
                                                      role: strongSelf.serverConfig.role.rawValue)
                                strongSelf.firebaseLoginManager?.saveUserToServerIfNeeded(user: atcUser, appIdentifier: strongSelf.serverConfig.appIdentifier)
                                strongSelf.delegate?.signUpManagerDidCompleteSignUp(strongSelf, user: atcUser)
                                strongSelf.viewModel.contactPoint = .phone
                                if let otpView = strongSelf.signUpScreen.otpView {
                                    otpView.isHidden = true
                                }
                                if let phoneNumberView = strongSelf.signUpScreen.phoneNumberView {
                                    phoneNumberView.isHidden = false
                                }
                                if let signUpButton = strongSelf.signUpScreen.signUpButton {
                                    signUpButton.setTitle(strongSelf.viewModel.sendCodeString, for: .normal)
                                }
                            }
                        } else {
                            self?.showSignUpError(text: error?.localizedDescription ?? "There was an error. Please try again later".localizedCore)
                        }
                    }
                } else {
                    self.showGenericSignUpError()
                }
                return
            }
            return
        }
        self.delegate?.signUpManagerDidCompleteSignUp(self, user: nil)
    }

    fileprivate func isValid(email: String, pass: String, firstName: String) -> Bool {
        if firstName.count < 2 {
            showSignUpError(text: "Name must be longer than 2 characters.".localizedCore)
            return false
        }

        if email.count < 2 {
            showSignUpError(text: "E-mail must not be empty.".localizedCore)
            return false
        }

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailPred.evaluate(with: email) {
            showSignUpError(text: "E-mail must have the correct format.".localizedCore)
            return false
        }

        if (pass.count < 6) {
            showSignUpError(text: "Password must be longer than 6 characters.".localizedCore)
            return false
        }
        return true
    }

    fileprivate func showGenericSignUpError() {
        self.showSignUpError(text: "There was an error during the registration process. Please check all the fields and try again.".localizedCore)
    }

    fileprivate func showSignUpError(text: String) {
        let alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: nil))
        self.signUpScreen.display(alertController: alert)
    }
}

extension ATCPhoneSignUpScreenManager: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let otpStackView = self.signUpScreen.otpStackView {
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
