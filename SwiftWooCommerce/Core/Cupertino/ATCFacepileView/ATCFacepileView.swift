//
//  ATCFacepileView.swift
//  ChatApp
//
//  Created by Mac  on 30/01/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

class ATCFacepileView: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var seenerFacepile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        seenerFacepile.layer.cornerRadius = seenerFacepile.frame.size.width / 2
        // Initialization code
    }

}
