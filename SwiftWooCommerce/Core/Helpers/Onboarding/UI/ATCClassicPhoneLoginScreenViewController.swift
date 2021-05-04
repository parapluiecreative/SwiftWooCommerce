//
//  ATCClassicPhoneLoginScreenViewController.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/9/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import AuthenticationServices
import UIKit

struct kPhoneVerificationConfig {
    static let phoneCode = "+1"
    static let countryFlag = UIImage(named: "US")
    static let otpCount: Int = 6
}

class ATCClassicPhoneLoginScreenViewController: UIViewController, ATCPhoneLoginScreenProtocol {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var passwordTextField: ATCTextField!
    @IBOutlet var contactPointTextField: ATCTextField!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var phoneCountryFlagIcon: UIImageView!
    @IBOutlet var phoneCountryFlagBtn: UIButton!
    @IBOutlet weak var phoneCountrySeperatorLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: ATCTextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var separatorLabel: UILabel!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet weak var appleSignInStackView: UIStackView!
    @IBOutlet weak var contactPointButton: UIButton!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpStackView: UIStackView!
    @IBOutlet weak var forgotPasswordButton: UIButton!

    weak var delegate: ATCPhoneLoginScreenDelegate?
    let uiConfig: ATCOnboardingConfigurationProtocol

    init(uiConfig: ATCOnboardingConfigurationProtocol) {
        self.uiConfig = uiConfig
        super.init(nibName: "ATCClassicPhoneLoginScreenViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.loginScreenDidLoadView(self)
        self.titleLabel.textColor = uiConfig.subtitleColor
        self.contactPointTextField.textColor = uiConfig.subtitleColor
        self.passwordTextField.textColor = uiConfig.subtitleColor
        self.facebookButton.setTitleColor(UIColor.white, for: .normal)
        backButton.tintColor = uiConfig.subtitleColor
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = uiConfig.backgroundColor

        setupProviderLoginView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    func display(alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }

    private func setupProviderLoginView() {
        if #available(iOS 13.0, *) {
            let style: ASAuthorizationAppleIDButton.Style = (ATCHostViewController.darkModeEnabled() ? .white : .black)
            let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn,
                                                                   authorizationButtonStyle: style)
            authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            self.appleSignInStackView.addArrangedSubview(authorizationButton)
        } else {
            // Fallback on earlier versions
            print("Apple Signin button not supported on this device.")
        }
    }

    @available(iOS 13.0, *)
    @objc private func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
extension ATCClassicPhoneLoginScreenViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = userIdentifier + "@applesignin.com"
            self.delegate?.loginScreen(self,
                                       didFetchAppleUserWith: fullName?.givenName,
                                       lastName: fullName?.familyName,
                                       email: email,
                                       password: userIdentifier)
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            self.delegate?.loginScreen(self,
                                       didFetchAppleUserWith: nil,
                                       lastName: nil,
                                       email: username,
                                       password: password)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension ATCClassicPhoneLoginScreenViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

