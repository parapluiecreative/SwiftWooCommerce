//
//  ATCProfileBasicViewController.swift
//  ClassifiedsApp
//
//  Created by Florian Marcu on 11/5/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCProfileBasicViewController: UIViewController {
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var fullNameLabel: UILabel!

    var configuration: ATCProfileScreenConfiguration
    var isOwnProfile: Bool {
        return configuration.viewee.uid == configuration.viewer.uid
    }
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         configuration: ATCProfileScreenConfiguration,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        self.configuration = configuration
        self.uiConfig = uiConfig
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fullNameLabel.text = configuration.viewee.fullName()
        fullNameLabel.font = uiConfig.boldSuperLargeFont
        fullNameLabel.textColor = uiConfig.mainTextColor

        dismissButton.configure(icon: UIImage.localImage("close-x-icon", template: true), color: uiConfig.mainThemeForegroundColor)
        dismissButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        if let url = configuration.viewee.profilePictureURL{
            avatarImageView.kf.setImage(with: URL(string: url))
        }
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = 75.0/2.0

        logoutButton.setTitle("Logout".localizedCore, for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }

    @objc fileprivate func didTapCloseButton() {
        self.dismiss(animated: false, completion: nil)
    }

    @objc fileprivate func didTapLogoutButton() {
        NotificationCenter.default.post(name: kLogoutNotificationName, object: nil)
        self.dismiss(animated: false, completion: nil)
    }
}
