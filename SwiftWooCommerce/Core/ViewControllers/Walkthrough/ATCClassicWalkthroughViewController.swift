//
//  ATCClassicWalkthroughViewController.swift
//  DashboardApp
//
//  Created by Florian Marcu on 8/13/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCClassicWalkthroughViewController: UIViewController {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    let model: ATCWalkthroughModel
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(model: ATCWalkthroughModel,
         uiConfig: ATCUIGenericConfigurationProtocol,
         nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?) {
        self.model = model
        self.uiConfig = uiConfig
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        imageView.image = UIImage.localImage(model.icon, template: true)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = uiConfig.mainThemeBackgroundColor
        imageContainerView.backgroundColor = .clear

        titleLabel.text = model.title
        titleLabel.font = uiConfig.boldFont(size: 28)
        titleLabel.textColor = uiConfig.mainThemeBackgroundColor

        subtitleLabel.attributedText = NSAttributedString(string: model.subtitle)
        subtitleLabel.font = uiConfig.regularFont(size: 18)
        subtitleLabel.textColor = uiConfig.mainThemeBackgroundColor

        containerView.backgroundColor = uiConfig.mainThemeForegroundColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.frame = self.view.bounds
    }
}
