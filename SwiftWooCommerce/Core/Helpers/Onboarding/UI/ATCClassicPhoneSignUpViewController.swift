//
//  ATCClassicPhoneSignUpViewController.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCClassicPhoneSignUpViewController: UIViewController, ATCPhoneSignUpScreenProtocol {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var firstNameTextField: ATCTextField!
    @IBOutlet var lastNameTextField: ATCTextField!
    @IBOutlet var passwordTextField: ATCTextField!
    @IBOutlet var emailTextField: ATCTextField!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var phoneCountryFlagIcon: UIImageView!
    @IBOutlet var phoneCountryFlagBtn: UIButton!
    @IBOutlet weak var phoneCountrySeperatorLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: ATCTextField!
    @IBOutlet var separatorLabel: UILabel!
    @IBOutlet weak var contactPointButton: UIButton!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpStackView: UIStackView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var textView: UITextView!

    weak var delegate: ATCPhoneSignUpScreenDelegate?

    let uiConfig: ATCOnboardingConfigurationProtocol

    init(uiConfig: ATCOnboardingConfigurationProtocol) {
        self.uiConfig = uiConfig
        super.init(nibName: "ATCClassicPhoneSignUpViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.signUpScreenDidLoadView(self)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        self.hideKeyboardWhenTappedAround()
        self.titleLabel.textColor = uiConfig.subtitleColor
        self.firstNameTextField.textColor = uiConfig.subtitleColor
        self.lastNameTextField.textColor = uiConfig.subtitleColor
        self.phoneNumberTextField.textColor = uiConfig.subtitleColor
        self.passwordTextField.textColor = uiConfig.subtitleColor
        self.emailTextField.textColor = uiConfig.subtitleColor
        backButton.tintColor = uiConfig.subtitleColor
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        let linkedText = "Terms of Use".localizedCore
        let string = "By creating an account you agree with our ".localizedCore + linkedText + "."
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.link,
                                      value: "https://www.instamobile.io/eula-instachatty/",
                                      range: NSRange(location: string.count - 1 - linkedText.count, length: linkedText.count))
        textView.attributedText = attributedString
        textView.delegate = self
        textView.textColor = .gray
        textView.textAlignment = .center
        textView.backgroundColor = uiConfig.backgroundColor
        self.view.backgroundColor = uiConfig.backgroundColor
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
}

extension ATCClassicPhoneSignUpViewController: UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        //UIApplication.shared.open(URL, options: [:])
        let webView = ATCWebViewController(url: URL, title: "Terms of Use")
        self.navigationController?.pushViewController(webView, animated: true)
        return false
    }

    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let url = URL(string: "") {
            UIApplication.shared.open(url, options: [:])
        }
        return false
    }
}
