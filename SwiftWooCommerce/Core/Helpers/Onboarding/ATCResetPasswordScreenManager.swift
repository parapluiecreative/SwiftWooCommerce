//
//  ATCResetPasswordScreenManager.swift
//  ChatApp
//
//  Created by Mac  on 20/02/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ATCResetPasswordScreenManagerDelegate: class {
    func resetPasswordManagerDidResetPassword(_ resetPasswordManager: ATCResetPasswordScreenManager)
}

class ATCResetPasswordScreenManager: NSObject, ATCResetPasswordScreenDelegate {
    let resetPasswordScreen: ATCResetPasswordScreenProtocol
    var viewModel: ATCResetPasswordScreenViewModel
    let uiConfig: ATCOnboardingConfigurationProtocol
    let serverConfig: ATCOnboardingServerConfigurationProtocol
    let firebaseLoginManager: ATCFirebaseLoginManager?

    weak var delegate: ATCResetPasswordScreenManagerDelegate?

    init(resetPasswordScreen: ATCResetPasswordScreenProtocol,
         viewModel: ATCResetPasswordScreenViewModel,
         uiConfig: ATCOnboardingConfigurationProtocol,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         userManager: ATCSocialUserManagerProtocol?) {
        self.resetPasswordScreen = resetPasswordScreen
        self.viewModel = viewModel
        self.uiConfig = uiConfig
        self.serverConfig = serverConfig
        self.firebaseLoginManager = serverConfig.isFirebaseAuthEnabled ? ATCFirebaseLoginManager(userManager: userManager) : nil
    }

    func resetPasswordScreenDidLoadView(_ resetPasswordScreen: ATCResetPasswordScreenProtocol) {
        if let titleLabel = resetPasswordScreen.titleLabel {
            titleLabel.font = uiConfig.titleFont
            titleLabel.text = viewModel.title
            titleLabel.textColor = uiConfig.titleColor
        }
        if let emailField = resetPasswordScreen.emailTextField {
            emailField.configure(color: uiConfig.textFieldColor,
                                font: uiConfig.signUpTextFieldFont,
                                cornerRadius: 55/2,
                                borderColor: uiConfig.textFieldBorderColor,
                                backgroundColor: uiConfig.textFieldBackgroundColor,
                                borderWidth: 1.0)
            emailField.placeholder = viewModel.emailField
            emailField.clipsToBounds = true
        }
        if let resetPasswordButton = resetPasswordScreen.resetPasswordButton {
            resetPasswordButton.setTitle(viewModel.resetPasswordString, for: .normal)
            resetPasswordButton.addTarget(self, action: #selector(didTapResetPasswordButton), for: .touchUpInside)
            resetPasswordButton.configure(color: uiConfig.loginButtonTextColor,
                                  font: uiConfig.loginButtonFont,
                                  cornerRadius: 8,
                                  backgroundColor: uiConfig.loginButtonBackgroundColor)
        }
    }
    
    @objc func didTapResetPasswordButton() {
        if serverConfig.isFirebaseAuthEnabled {
            if let email = resetPasswordScreen.emailTextField.text, !email.isEmpty {
                let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                hud.show(in: resetPasswordScreen.view)
                Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                    hud.dismiss()
                    if let error = error {
                        self.showResetPasswordError(error.localizedDescription)
                    } else {
                        self.showResetPasswordSuccess()
                    }
                }
            } else {
                self.showResetPasswordError()
            }
        }
    }
    
    fileprivate func showResetPasswordSuccess(_ title: String? = "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password".localizedCore) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.resetPasswordManagerDidResetPassword(strongSelf)
        }))
        self.resetPasswordScreen.display(alertController: alert)
    }

    fileprivate func showResetPasswordError(_ title: String? = "E-mail is invalid. Please try again".localizedCore) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: nil))
        self.resetPasswordScreen.display(alertController: alert)
    }
}
