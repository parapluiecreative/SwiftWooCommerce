//
//  ATCPhoneLoginManager.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/8/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCLandingScreenManagerDelegate: class {
    func landingScreenManagerDidTapLogIn(manager: ATCLandingScreenManager)
    func landingScreenManagerDidTapSignUp(manager: ATCLandingScreenManager)
}

class ATCLandingScreenManager: ATCLandingScreenDelegate {
    let landingScreen: ATCLandingScreenProtocol
    let viewModel: ATCLandingScreenViewModel
    let uiConfig: ATCOnboardingConfigurationProtocol
    weak var delegate: ATCLandingScreenManagerDelegate?

    init(landingScreen: ATCLandingScreenProtocol,
         viewModel: ATCLandingScreenViewModel,
         uiConfig: ATCOnboardingConfigurationProtocol) {
        self.landingScreen = landingScreen
        self.viewModel = viewModel
        self.uiConfig = uiConfig
    }

    func landingScreenDidLoadView(_ landingScreen: ATCLandingScreenProtocol) {
        if let imageView = landingScreen.logoImageView {
            if let tintColor = uiConfig.logoTintColor {
                imageView.image = UIImage.localImage(viewModel.imageIcon, template: true)
                imageView.tintColor = tintColor
            } else {
                imageView.image = UIImage.localImage(viewModel.imageIcon)
            }
        }

        if let titleLabel = landingScreen.titleLabel {
            titleLabel.font = uiConfig.titleFont
            titleLabel.text = viewModel.title
            titleLabel.textColor = uiConfig.titleColor
        }

        if let subtitleLabel = landingScreen.subtitleLabel {
            subtitleLabel.font = uiConfig.subtitleFont
            subtitleLabel.text = viewModel.subtitle
            subtitleLabel.textColor = uiConfig.subtitleColor
        }

        if let loginButton = landingScreen.loginButton {
            loginButton.setTitle(viewModel.loginString, for: .normal)
            loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
            loginButton.configure(color: uiConfig.loginButtonTextColor,
                                  font: uiConfig.loginButtonFont,
                                  cornerRadius: 55/2,
                                  backgroundColor: uiConfig.loginButtonBackgroundColor)
        }

        if let signUpButton = landingScreen.signUpButton {
            signUpButton.setTitle(viewModel.signUpString, for: .normal)
            signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
            signUpButton.configure(color: uiConfig.signUpButtonTextColor,
                                   font: uiConfig.signUpButtonFont,
                                   cornerRadius: 55/2,
                                   borderColor: uiConfig.signUpButtonBorderColor,
                                   backgroundColor: uiConfig.signUpButtonBackgroundColor,
                                   borderWidth: 1)
        }
    }

    @objc func didTapLoginButton() {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
        delegate?.landingScreenManagerDidTapLogIn(manager: self)
    }

    @objc func didTapSignUpButton() {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
        delegate?.landingScreenManagerDidTapSignUp(manager: self)
    }
}
