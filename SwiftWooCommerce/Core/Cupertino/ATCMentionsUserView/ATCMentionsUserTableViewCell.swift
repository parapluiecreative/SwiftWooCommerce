//
//  ATCMentionsUserTableViewCell.swift
//  ChatApp
//
//  Created by Mac  on 03/03/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

class ATCMentionsUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var seperatorLabel: UILabel!
    
    public func setUserData(_ userData: ATCUser, uiConfig: ATCChatUIConfigurationProtocol) {
        self.backgroundColor = uiConfig.backgroundColor
        self.lblName.text = userData.fullName()
        self.lblName.textColor = uiConfig.inputTextViewTextColor
        self.seperatorLabel.backgroundColor = UIColor.darkModeColor(hexString: "#e6e6e6")
        if let imagePath = userData.profilePictureURL {
            self.userImgView.kf.setImage(with: URL(string: imagePath))
        }
    }
}
