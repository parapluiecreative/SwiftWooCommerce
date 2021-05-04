//
//  ATCNotificationCollectionViewCell.swift
//  DashboardApp
//
//  Created by Florian Marcu on 7/28/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCNotificationCollectionViewCell: UICollectionViewCell {
    @IBOutlet var notificationContainerView: UIView!
    @IBOutlet var badgeView: UIView!
    @IBOutlet var hairlineView: UIView!
    @IBOutlet var notificationImageView: UIImageView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
}
