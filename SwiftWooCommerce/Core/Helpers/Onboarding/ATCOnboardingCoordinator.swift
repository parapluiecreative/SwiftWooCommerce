//
//  ATCOnboardingCoordinator.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/8/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCOnboardingCoordinatorDelegate: class {
    func coordinatorDidCompleteOnboarding(_ coordinator: ATCOnboardingCoordinatorProtocol, user: ATCUser?)
    func coordinatorDidResyncCredentials(_ coordinator: ATCOnboardingCoordinatorProtocol, user: ATCUser?)
}

protocol ATCOnboardingCoordinatorProtocol: ATCLandingScreenManagerDelegate {
    func viewController() -> UIViewController
    var delegate: ATCOnboardingCoordinatorDelegate? {get set}
    func resyncPersistentCredentials(user: ATCUser) -> Void
}

class ATCClassicOnboardingCoordinator: ATCOnboardingCoordinatorProtocol, ATCLoginScreenManagerDelegate, ATCPhoneLoginScreenManagerDelegate, ATCSignUpScreenManagerDelegate, ATCPhoneSignUpScreenManagerDelegate, ATCResetPasswordScreenManagerDelegate {
    weak var delegate: ATCOnboardingCoordinatorDelegate?

    let landingManager: ATCLandingScreenManager
    let landingScreen: ATCClassicLandingScreenViewController

    let loginManager: ATCLoginScreenManager
    let loginScreen: ATCClassicLoginScreenViewController

    let phoneLoginManager: ATCPhoneLoginScreenManager
    let phoneLoginScreen: ATCClassicPhoneLoginScreenViewController

    let signUpManager: ATCSignUpScreenManager
    let signUpScreen: ATCClassicSignUpViewController

    let phoneSignUpManager: ATCPhoneSignUpScreenManager
    let phoneSignUpScreen: ATCClassicPhoneSignUpViewController

    let resetPasswordManager: ATCResetPasswordScreenManager
    let resetPasswordScreen: ATCClassicResetPasswordViewController

    let countryCodePickerScreen: CountryCodePickerViewController

    let navigationController: UINavigationController

    let serverConfig: ATCOnboardingServerConfigurationProtocol
    let firebaseLoginManager: ATCFirebaseLoginManager?

    init(landingViewModel: ATCLandingScreenViewModel,
         loginViewModel: ATCLoginScreenViewModel,
         phoneLoginViewModel: ATCPhoneLoginScreenViewModel,
         signUpViewModel: ATCSignUpScreenViewModel,
         phoneSignUpViewModel: ATCPhoneSignUpScreenViewModel,
         resetPasswordViewModel: ATCResetPasswordScreenViewModel,
         uiConfig: ATCOnboardingConfigurationProtocol,
         serverConfig: ATCOnboardingServerConfigurationProtocol,
         userManager: ATCSocialUserManagerProtocol?) {
        self.serverConfig = serverConfig
        self.firebaseLoginManager = serverConfig.isFirebaseAuthEnabled ? ATCFirebaseLoginManager(userManager: userManager) : nil
        self.landingScreen = ATCClassicLandingScreenViewController(uiConfig: uiConfig)
        self.landingManager = ATCLandingScreenManager(landingScreen: self.landingScreen, viewModel: landingViewModel, uiConfig: uiConfig)
        self.landingScreen.delegate = landingManager

        self.loginScreen = ATCClassicLoginScreenViewController(uiConfig: uiConfig)
        self.loginManager = ATCLoginScreenManager(loginScreen: self.loginScreen,
                                                  viewModel: loginViewModel,
                                                  uiConfig: uiConfig,
                                                  serverConfig: serverConfig,
                                                  userManager: userManager)
        self.loginScreen.delegate = loginManager

        self.phoneLoginScreen = ATCClassicPhoneLoginScreenViewController(uiConfig: uiConfig)
        self.phoneLoginManager = ATCPhoneLoginScreenManager(loginScreen: self.phoneLoginScreen,
                                                  viewModel: phoneLoginViewModel,
                                                  uiConfig: uiConfig,
                                                  serverConfig: serverConfig,
                                                  userManager: userManager)
        self.phoneLoginScreen.delegate = phoneLoginManager

        self.signUpScreen = ATCClassicSignUpViewController(uiConfig: uiConfig)
        self.signUpManager = ATCSignUpScreenManager(signUpScreen: self.signUpScreen,
                                                    viewModel: signUpViewModel,
                                                    uiConfig: uiConfig,
                                                    serverConfig: serverConfig,
                                                    userManager: userManager)
        self.signUpScreen.delegate = signUpManager

        self.phoneSignUpScreen = ATCClassicPhoneSignUpViewController(uiConfig: uiConfig)
        self.phoneSignUpManager = ATCPhoneSignUpScreenManager(signUpScreen: self.phoneSignUpScreen,
                                                              viewModel: phoneSignUpViewModel,
                                                              uiConfig: uiConfig,
                                                              serverConfig: serverConfig,
                                                              userManager: userManager)
        self.phoneSignUpScreen.delegate = phoneSignUpManager

        self.resetPasswordScreen = ATCClassicResetPasswordViewController(uiConfig: uiConfig)
        self.resetPasswordManager = ATCResetPasswordScreenManager(resetPasswordScreen: self.resetPasswordScreen,
                                                                  viewModel: resetPasswordViewModel,
                                                                  uiConfig: uiConfig,
                                                                  serverConfig: serverConfig,
                                                                  userManager: userManager)
        self.resetPasswordScreen.delegate = resetPasswordManager
        
        self.navigationController = UINavigationController(rootViewController: landingScreen)

        self.countryCodePickerScreen = CountryCodePickerViewController(uiConfig: uiConfig)
        self.countryCodePickerScreen.delegate = self
        
        self.landingManager.delegate = self
        self.loginManager.delegate = self
        self.phoneLoginManager.delegate = self
        self.signUpManager.delegate = self
        self.phoneSignUpManager.delegate = self
        self.resetPasswordManager.delegate = self
    }

    func viewController() -> UIViewController {
        return navigationController
    }

    func resyncPersistentCredentials(user: ATCUser) -> Void {        
        if serverConfig.isFirebaseAuthEnabled {
            self.firebaseLoginManager?.resyncPersistentUser(user: user) {[weak self] (syncedUser, error) in
                guard let `self` = self else { return }
                self.delegate?.coordinatorDidResyncCredentials(self, user: syncedUser)
            }
        } else {
            self.delegate?.coordinatorDidResyncCredentials(self, user: user)
        }
    }

    func landingScreenManagerDidTapLogIn(manager: ATCLandingScreenManager) {
        var vc: UIViewController
        if serverConfig.isPhoneAuthEnabled {
            vc = self.phoneLoginScreen
        } else {
            vc = self.loginScreen
        }
        self.navigationController.pushViewController(vc, animated: true)
    }

    func landingScreenManagerDidTapSignUp(manager: ATCLandingScreenManager) {
        var vc: UIViewController
        if serverConfig.isPhoneAuthEnabled {
            vc = self.phoneSignUpScreen
        } else {
            vc = self.signUpScreen
        }
        self.navigationController.pushViewController(vc, animated: true)
    }

    func loginManagerDidCompleteLogin(_ loginManager: ATCPhoneLoginScreenManager, user: ATCUser?) {
        self.delegate?.coordinatorDidCompleteOnboarding(self, user: user)
    }

    func loginManagerDidCompleteLogin(_ loginManager: ATCLoginScreenManager, user: ATCUser?) {
        self.delegate?.coordinatorDidCompleteOnboarding(self, user: user)
    }

    func signUpManagerDidCompleteSignUp(_ signUpManager: ATCSignUpScreenManager, user: ATCUser?) {
        self.delegate?.coordinatorDidCompleteOnboarding(self, user: user)
    }
    
    func signUpManagerDidCompleteSignUp(_ signUpManager: ATCPhoneSignUpScreenManager, user: ATCUser?) {
        self.delegate?.coordinatorDidCompleteOnboarding(self, user: user)
    }

    func phoneLoginManagerDidTapCountryFlagButton(_ loginManager: ATCPhoneLoginScreenManager) {
        self.countryCodePickerScreen.modalPresentationStyle = .overCurrentContext
        self.phoneLoginScreen.present(self.countryCodePickerScreen, animated: true, completion: nil)
    }
    
    func tapPhoneSignUpCountryFlagButton() {
        self.countryCodePickerScreen.modalPresentationStyle = .overCurrentContext
        self.phoneSignUpScreen.present(self.countryCodePickerScreen, animated: true, completion: nil)
    }
    
    func loginManagerDidTapForgotPasswordButton(_ loginManager: ATCLoginScreenManager) {
        self.navigationController.pushViewController(self.resetPasswordScreen, animated: true)
    }
    
    func tapPhoneLoginForgotPasswordButton(_ loginManager: ATCPhoneLoginScreenManager) {
        self.navigationController.pushViewController(self.resetPasswordScreen, animated: true)
    }
    
    func resetPasswordManagerDidResetPassword(_ resetPasswordManager: ATCResetPasswordScreenManager) {
        self.navigationController.popViewController(animated: true)
    }
}

extension ATCClassicOnboardingCoordinator: CountryCodePickerProtocol {
    func didSelectCountryCode(country: Country) {
        self.phoneLoginManager.country = country
        self.phoneLoginManager.viewModel.phoneCodeString = country.phoneCode
        self.phoneSignUpManager.country = country
        self.phoneSignUpManager.viewModel.phoneCodeString = country.phoneCode
    }
}
