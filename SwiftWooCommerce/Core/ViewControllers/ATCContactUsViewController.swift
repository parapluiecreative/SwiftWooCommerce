//
//  ATCContactUsViewController.swift
//  RadioApp
//
//  Created by Marius Popescu on 6/12/18.
//  Copyright © 2018 Marius Popescu. All rights reserved.
//

import UIKit

protocol ATCContactUsUITheme {
    var mainTitleColor: UIColor {get}
    var mainSubtitleColor: UIColor {get}

    var callToActionColor: UIColor {get}
    var callToActionBtnColor: UIColor {get}

    var socialMediaTextColor: UIColor {get}
    var socialMediaIconColor: UIColor {get}

    var backgroundColor: UIColor {get}
}

protocol ATCContactUsCallToAction {
    var actionDescription: String {get}
    var actionButtonText: String {get}
    var actionUrl: String {get}
}

enum ATCSocialMediaType: String {
    case Facebook = "icn-fb"
    case Twitter = "icn-twtr"
    case Youtube = "icn-youtube"
    case Instagram = "icn-instagram"
}

struct ATCSocialMedia {
    let type: ATCSocialMediaType
    let url: String
}

protocol ATCContactUsViewModel {
    var mainTitle: String {get}
    var mainSubtitle: String {get}
    var callToAction: ATCContactUsCallToAction {get}
    var socialMediaText: String {get}
    var socialMediaActions: [ATCSocialMedia] {get}
}

class ATCContactUsViewController: UIViewController {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainSubtitleLabel: UILabel!

    @IBOutlet weak var callToActionLabel: UILabel!
    @IBOutlet weak var callToActionButton: UIButton!

    @IBOutlet weak var socialMediaLabel: UILabel!
    @IBOutlet weak var socialMediaView: UIView!
    
    let viewModel: ATCContactUsViewModel
    let uiTheme: ATCContactUsUITheme

    var socialMediaButtons: [UIButton]

    init(viewModel: ATCContactUsViewModel, uiTheme: ATCContactUsUITheme,  nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = viewModel
        self.uiTheme = uiTheme
        self.socialMediaButtons = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutSocialMediaButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = uiTheme.backgroundColor

        // Header
        mainLabel.text = viewModel.mainTitle
        mainLabel.textColor = uiTheme.mainTitleColor
        mainSubtitleLabel.text = viewModel.mainSubtitle
        mainSubtitleLabel.textColor = uiTheme.mainSubtitleColor

        // Call To Action
        callToActionLabel.text = viewModel.callToAction.actionDescription
        callToActionLabel.textColor = uiTheme.callToActionColor
        callToActionButton.setTitle(viewModel.callToAction.actionButtonText, for: .normal)
        callToActionButton.tintColor = uiTheme.callToActionBtnColor

        // Social Media
        socialMediaLabel.text = viewModel.socialMediaText
        socialMediaLabel.textColor = uiTheme.socialMediaTextColor

        addSocialMediaButtons()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func callToActionPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string : viewModel.callToAction.actionUrl)!, options: [:], completionHandler:nil)
    }
    private func layoutSocialMediaButtons() {
        let bounds = socialMediaView.bounds
        let totalWidth = Int(bounds.width)
        let preferredBtnWidth = 40
        let noOfRenderedBtns = min(totalWidth / preferredBtnWidth, socialMediaButtons.count)
        for index in 0..<noOfRenderedBtns {
            let btn = socialMediaButtons[index]
            let spacing = (totalWidth - (noOfRenderedBtns + 1) * preferredBtnWidth) / (noOfRenderedBtns)
            btn.frame = CGRect(x: (index + 1) * spacing + (index * preferredBtnWidth), y: 0, width: preferredBtnWidth, height: preferredBtnWidth)
        }
    }

    private func addSocialMediaButtons() {
        for (index, socialMediaAction) in viewModel.socialMediaActions.enumerated() {
            let btn = UIButton.init(type: .custom)
            btn.configure(icon: UIImage.localImage(socialMediaAction.type.rawValue, template: true))
            btn.backgroundColor = .clear
            btn.tintColor = uiTheme.socialMediaIconColor
            btn.tag = index
            btn.setTitle(nil, for: .normal)
            btn.addTarget(self, action: #selector(socialMediaButtonPressed), for: .touchUpInside)
            socialMediaButtons.append(btn)
            socialMediaView.addSubview(btn)
        }
        layoutSocialMediaButtons()
    }

    @objc func socialMediaButtonPressed(sender:UIButton) {
        UIApplication.shared.open(URL(string : viewModel.socialMediaActions[sender.tag].url)!, options: [:], completionHandler:nil)
    }
}
